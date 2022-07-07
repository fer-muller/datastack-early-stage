locals {

  # General
  environment = "development"
}

module "aws_data_pipeline" {
  # GENERAL VARIABLES
  source      = "../../aws-data-pipeline"
  environment = var.environment
  deployment  = var.deployment
  region      = var.region
  prefix      = var.prefix
  stack_id    = var.stack_id
  account_id  = var.account_id
  tags        = var.tags
  events      = var.events

  #S3 VARIABLES
  bucket_name = var.deployment

  #LAMBDA VARIABLES
  lambda_suffix                     = "worker"
  lambda_sqs_deadqueue_filename     = "SQSDeadQueue"
  lambda_sns_deadqueue_filename     = "SNSDeadQueue"
  lambda_handler_pattern_name       = "lambda_handler"
  lambda_origin_app_event_name      = "my-app"
  lambda_raw_data_s3_stage_name     = "raw"
  lambda_staging_data_s3_stage_name = "staging"
  lambda_log_s3_stage_name          = "log"
  lambda_runtime                    = "python3.8"
  lambda_default_timeout            = 60
  lambda_default_concurrency        = 5
  lambda_zip_scripts_path           = "${path.root}/modules/aws-data-pipeline/lambda_scripts/worker"
  lambda_event_generator_zip_scripts_path           = "${path.root}/modules/aws-data-pipeline/lambda_scripts/faker"

  #SQS VARIABLES
  sqs_delay_seconds             = 0
  sqs_max_message_size          = 262144
  sqs_message_retention_seconds = 345600
  sqs_receive_wait_time_seconds = 0
  sqs_deadletter_suffix         = "sqs-deadletter"
  sqs_sns_deadletter_suffix     = "sns-deadletter"
  sqs_managed_sse_enabled       = true

  sns_arn = aws_sns_topic.data_sns.arn
}