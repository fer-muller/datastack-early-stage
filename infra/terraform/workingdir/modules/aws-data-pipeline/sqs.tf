locals {
  visibility_timeout_seconds = var.lambda_default_timeout
}

resource "aws_sqs_queue" "etl_queues" {
  depends_on = [
    aws_sqs_queue.etl_dead_queue
  ]
  for_each                   = var.events
  name                       = "${var.deployment}-${each.value}"
  sqs_managed_sse_enabled    = var.sqs_managed_sse_enabled
  delay_seconds              = var.sqs_delay_seconds
  max_message_size           = var.sqs_max_message_size
  message_retention_seconds  = var.sqs_message_retention_seconds
  receive_wait_time_seconds  = var.sqs_receive_wait_time_seconds
  visibility_timeout_seconds = local.visibility_timeout_seconds
  redrive_policy = jsonencode({
    deadLetterTargetArn = "${aws_sqs_queue.etl_dead_queue.arn}"
    maxReceiveCount     = 3
  })
  tags = var.tags
}

resource "aws_sqs_queue" "etl_dead_queue" {
  name                       = "${var.deployment}-${var.sqs_deadletter_suffix}"
  sqs_managed_sse_enabled    = var.sqs_managed_sse_enabled
  delay_seconds              = var.sqs_delay_seconds
  max_message_size           = var.sqs_max_message_size
  message_retention_seconds  = var.sqs_message_retention_seconds
  receive_wait_time_seconds  = var.sqs_receive_wait_time_seconds
  visibility_timeout_seconds = local.visibility_timeout_seconds
  tags                       = var.tags
}

resource "aws_sqs_queue" "sns_dead_queue" {
  name                       = "${var.deployment}-${var.sqs_sns_deadletter_suffix}"
  sqs_managed_sse_enabled    = var.sqs_managed_sse_enabled
  delay_seconds              = var.sqs_delay_seconds
  max_message_size           = var.sqs_max_message_size
  message_retention_seconds  = var.sqs_message_retention_seconds
  receive_wait_time_seconds  = var.sqs_receive_wait_time_seconds
  visibility_timeout_seconds = local.visibility_timeout_seconds
  tags                       = var.tags
}

####################### SQS SUPPORTING RESOURCES #########################

# SQS Event ETL Policy
resource "aws_sqs_queue_policy" "etl_queues" {
  depends_on = [
    aws_sqs_queue.etl_queues
  ]
  for_each = tomap({
    for i, j in aws_sqs_queue.etl_queues : i => j.id }
  )
  queue_url = each.value
  policy    = data.aws_iam_policy_document.ssm_params_etl_queues.json
}

# SQS Event ETL Policy Document
data "aws_iam_policy_document" "ssm_params_etl_queues" {
  version = "2012-10-17"

  statement {
    actions = [
      "sqs:SendMessage",
      "sqs:GetQueueAttributes",
      "sqs:SetQueueAttributes",
      "sqs:ReceiveMessage",
      "sqs:GetQueueUrl"
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    resources = ["arn:aws:sqs:${var.region}:${var.account_id}*"]

    sid = "SNSSQSPolicy"
  }

  statement {
    actions = [
      "SNS:GetTopicAttributes",
      "SNS:Subscribe",
      "SNS:ConfirmSubscription",
      "SNS:GetSubscriptionAttributes",
      "SNS:GetEndpointAttributes",
      "SNS:SetEndpointAttributes",
      "SNS:SetSubscriptionAttributes",
      "SNS:SetTopicAttributes"
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    resources = ["arn:aws:sns:${var.region}:${var.account_id}*"]

    sid = "SubscriptionPolicy"
  }
}

# SNS Dead Queue Policy
resource "aws_sqs_queue_policy" "sns_dead_queue" {
  depends_on = [
    aws_sqs_queue.sns_dead_queue
  ]
  queue_url = aws_sqs_queue.sns_dead_queue.id
  policy    = data.aws_iam_policy_document.ssm_params_sns_dead_queue.json
}

# SNS Dead Queue Policy Document
data "aws_iam_policy_document" "ssm_params_sns_dead_queue" {
  version = "2012-10-17"

  statement {
    actions = [
      "sqs:SendMessage",
      "sqs:GetQueueAttributes",
      "sqs:SetQueueAttributes",
      "sqs:ReceiveMessage",
      "sqs:GetQueueUrl"
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    resources = ["arn:aws:sqs:${var.region}:${var.account_id}*"]

    sid = "SNSSQSPolicy"
  }
  statement {
    actions = [
      "SNS:GetTopicAttributes",
      "SNS:Subscribe",
      "SNS:ConfirmSubscription",
      "SNS:GetSubscriptionAttributes",
      "SNS:GetEndpointAttributes",
      "SNS:SetEndpointAttributes",
      "SNS:SetSubscriptionAttributes",
      "SNS:SetTopicAttributes"
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    resources = ["arn:aws:sns:${var.region}:${var.account_id}*"]

    sid = "SubscriptionPolicy"
  }
}

# SQS ETL Events Dead Queue Policy
resource "aws_sqs_queue_policy" "etl_dead_queue" {
  depends_on = [
    aws_sqs_queue.etl_dead_queue
  ]
  queue_url = aws_sqs_queue.etl_dead_queue.id
  policy    = data.aws_iam_policy_document.ssm_params_etl_dead_queue.json
}

# SQS ETL Events Dead Queue Policy Document
data "aws_iam_policy_document" "ssm_params_etl_dead_queue" {
  version = "2012-10-17"

  statement {
    actions = [
      "sqs:SendMessage",
      "sqs:GetQueueAttributes",
      "sqs:SetQueueAttributes",
      "sqs:ReceiveMessage",
      "sqs:GetQueueUrl"
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    resources = ["arn:aws:sqs:${var.region}:${var.account_id}*"]

    sid = "SNSSQSPolicy"
  }
  statement {
    actions = [
      "SNS:GetTopicAttributes",
      "SNS:Subscribe",
      "SNS:ConfirmSubscription",
      "SNS:GetSubscriptionAttributes",
      "SNS:GetEndpointAttributes",
      "SNS:SetEndpointAttributes",
      "SNS:SetSubscriptionAttributes",
      "SNS:SetTopicAttributes"
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    resources = ["arn:aws:sns:${var.region}:${var.account_id}*"]

    sid = "SubscriptionPolicy"
  }
}
