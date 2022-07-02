output "main_bucket_name" {
  value = module.sqs_lambda_s3.main_bucket_name
}

output "main_bucket_arn" {
  value = module.sqs_lambda_s3.main_bucket_arn
}

output "sqs_etl_arns" {
  value = module.sqs_lambda_s3.sqs_etl_arns
}

output "sqs_deadletter" {
  value = module.sqs_lambda_s3.sqs_deadletter
}

output "sns_deadletter" {
  value = module.sqs_lambda_s3.sqs_deadletter
}