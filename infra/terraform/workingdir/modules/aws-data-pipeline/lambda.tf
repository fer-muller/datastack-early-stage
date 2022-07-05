locals {
  tmp_folder_path = "/tmp/"

  # This layer is the version 2 for Python 3.8 runtime using sa-east-1
  # This ARN may change over time for new updates. Make sure to check if this is the last version
  layers = ["arn:aws:lambda:sa-east-1:336392948345:layer:AWSDataWrangler-Python38:2"]
}

resource "aws_lambda_function" "sqs_worker" {
  depends_on = [
    aws_s3_bucket_object.lambda_files
  ]
  for_each                       = var.events
  s3_bucket                      = "${module.s3_bucket_artifact.s3_bucket_id}"
  s3_key                         = "${each.value}.zip"
  function_name                  = "${var.deployment}-${each.key}-${var.lambda_suffix}"
  role                           = aws_iam_role.iam_for_lambda.arn
  handler                        = "${each.value}.${var.lambda_handler_pattern_name}"
  #source_code_hash               = filebase64sha256("${module.s3_bucket_artifact.s3_bucket_id}/${each.key}/artifact.zip")
  runtime                        = var.lambda_runtime
  timeout                        = var.lambda_default_timeout
  reserved_concurrent_executions = var.lambda_default_concurrency
  layers = local.layers

  environment {
    variables = {
      EVENT_BUCKET_NAME    = "${module.s3_bucket.s3_bucket_id}"
      EVENT_S3_RAW_KEY     = "${var.lambda_raw_data_s3_stage_name}/${var.lambda_origin_app_event_name}/${each.key}/"
      EVENT_S3_STAGING_KEY = "${var.lambda_staging_data_s3_stage_name}/${var.lambda_origin_app_event_name}/${each.key}/"
      EVENT_TEMP_FOLDER    = "${local.tmp_folder_path}"
      ORIGIN_APP           = "${var.lambda_origin_app_event_name}"
      APP_EVENT            = "${each.key}"
    }
  }
  tags = var.tags
}

resource "aws_lambda_function" "sqs_deadletter" {
  depends_on = [
    aws_s3_bucket_object.lambda_files
  ]
  s3_bucket                      = "${module.s3_bucket_artifact.s3_bucket_id}"
  s3_key                         = "${var.lambda_sqs_deadqueue_filename}.zip"
  function_name                  = "${var.deployment}-${var.lambda_sqs_deadqueue_filename}-${var.lambda_suffix}"
  role                           = aws_iam_role.iam_for_lambda.arn
  handler                        = "${var.lambda_sqs_deadqueue_filename}.${var.lambda_handler_pattern_name}"
  #source_code_hash               = filebase64sha256("${module.s3_bucket_artifact.s3_bucket_id}/${var.lambda_sqs_deadqueue_filename}/artifact.zip")
  runtime                        = var.lambda_runtime
  timeout                        = var.lambda_default_timeout
  reserved_concurrent_executions = var.lambda_default_concurrency
  layers = local.layers

  environment {
    variables = {
      EVENT_BUCKET_NAME = "${module.s3_bucket.s3_bucket_id}"
      EVENT_S3_KEY      = "${var.lambda_log_s3_stage_name}/${var.lambda_origin_app_event_name}/${var.lambda_sqs_deadqueue_filename}/"
      EVENT_TEMP_FOLDER = "${local.tmp_folder_path}"
      ORIGIN_APP        = "${var.lambda_origin_app_event_name}"
      APP_EVENT         = "${var.lambda_sqs_deadqueue_filename}"
    }
  }
  tags = var.tags
}

resource "aws_lambda_function" "sns_deadletter" {
  depends_on = [
    aws_s3_bucket_object.lambda_files
  ]
  s3_bucket                      = "${module.s3_bucket_artifact.s3_bucket_id}"
  s3_key                         = "${var.lambda_sns_deadqueue_filename}.zip"
  function_name                  = "${var.deployment}-${var.lambda_sns_deadqueue_filename}-${var.lambda_suffix}"
  role                           = aws_iam_role.iam_for_lambda.arn
  handler                        = "${var.lambda_sns_deadqueue_filename}.${var.lambda_handler_pattern_name}"
  #source_code_hash               = filebase64sha256("${module.s3_bucket_artifact.s3_bucket_id}/${var.lambda_sns_deadqueue_filename}/artifact.zip")
  runtime                        = var.lambda_runtime
  timeout                        = var.lambda_default_timeout
  reserved_concurrent_executions = var.lambda_default_concurrency
  layers = local.layers

  environment {
    variables = {
      EVENT_BUCKET_NAME = "${module.s3_bucket.s3_bucket_id}"
      EVENT_S3_KEY      = "${var.lambda_log_s3_stage_name}/${var.lambda_origin_app_event_name}/${var.lambda_sns_deadqueue_filename}/"
      EVENT_TEMP_FOLDER = "${local.tmp_folder_path}"
      ORIGIN_APP        = "${var.lambda_origin_app_event_name}"
      APP_EVENT         = "${var.lambda_sns_deadqueue_filename}"
    }
  }
  tags = var.tags
}


resource "aws_s3_bucket_object" "lambda_files" {
  for_each      = fileset("${var.lambda_zip_scripts_path}/", "*.zip")
  bucket        = module.s3_bucket_artifact.s3_bucket_id
  key           = "${each.value}"
  source        = "${var.lambda_zip_scripts_path}/${each.value}"
  etag          = filemd5("${var.lambda_zip_scripts_path}/${each.value}")
}

####################### LAMBDA SUPPORTING RESOURCES #########################

# Lambda IAM Role
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
          "Service": ["lambda.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": "IAMLambda"
    }
  ]
}
EOF
}

# Lambda Policy Document
data "aws_iam_policy_document" "ssm_params_lambda" {
  version = "2012-10-17"

  statement {
    sid = "AllowLambdaReceiveMessage"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:SendMessage"
    ]

    resources = ["arn:aws:sqs:${var.region}:${var.account_id}*"]
  }

  statement {
    sid = "AllowLambdaPutObjects"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]

    resources = [
      "${module.s3_bucket.s3_bucket_arn}*",
      "${module.s3_bucket_artifact.s3_bucket_arn}*"
    ]
  }

  statement {
    sid = "LambdaLayer"
    actions = [
      "lambda:GetLayerVersion",
      "lambda:DeleteLayerVersion",
      "lambda:PublishLayerVersion"
    ]

    resources = ["arn:aws:lambda:${var.region}:${var.account_id}:layer:*"]
  }

  statement {
    actions = [
      "sns:Publish",
      "sns:Subscribe",
      "sns:CreateTopic",
      "sns:GetTopicAttributes",
      "sns:SetTopicAttributes",
      "sns:TagResource",
      "sns:UntagResource",
      "sns:ListTagsForResource",
      "sns:ListSubscriptionsByTopic"
    ]

    effect = "Allow"

    resources = ["arn:aws:sns:${var.region}:${var.account_id}*"]
  }
}

# Lambda Basic Execution Policy
resource "aws_iam_role_policy_attachment" "basic_lambda" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.iam_for_lambda.name
}

# Lambda IAM Policy
resource "aws_iam_policy" "ssm_params_lambda" {
  name   = "lambda_ssm_params"
  policy = data.aws_iam_policy_document.ssm_params_lambda.json
}

# Lambda IAM Role Policy Attachment
resource "aws_iam_role_policy_attachment" "ssm_params_lambda" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.ssm_params_lambda.arn
}
