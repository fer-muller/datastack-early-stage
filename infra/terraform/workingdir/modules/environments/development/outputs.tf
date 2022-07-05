output "main_bucket_name" {
  value = module.aws_data_pipeline.main_bucket_name
}

output "main_bucket_arn" {
  value = module.aws_data_pipeline.main_bucket_arn
}

output "sqs_etl_arns" {
  value = module.aws_data_pipeline.sqs_etl_arns
}

output "sqs_deadletter" {
  value = module.aws_data_pipeline.sqs_deadletter
}

output "sns_deadletter" {
  value = module.aws_data_pipeline.sqs_deadletter
}

output "sns_topic_arn" {
  value = aws_sns_topic.data_sns.arn
}

output "lambda_etl_arn" {
  value = module.aws_data_pipeline.lambda_etl_arn
}

output "lambda_sqs_deadletter_arn" {
  value = module.aws_data_pipeline.sqs_deadletter
}

output "lambda_sns_deadletter_arn" {
  value = module.aws_data_pipeline.sns_deadletter
}