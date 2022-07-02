output "main_bucket_name" {
  value = module.development[*].main_bucket_name
}

output "main_bucket_arn" {
  value = module.development[*].main_bucket_arn
}

output "sqs_etl_arns" {
  value = module.development[*].sqs_etl_arns
}

output "sqs_deadletter" {
  value = module.development[*].sqs_deadletter
}

output "sns_deadletter" {
  value = module.development[*].sqs_deadletter
}

output "sns_topic_arn" {
  value = module.development[*].sns_topic_arn
}

output "lambda_etl_arn" {
  value = module.development[*].lambda_etl_arn
}

output "lambda_sqs_deadletter_arn" {
  value = module.development[*].sqs_deadletter
}

output "lambda_sns_deadletter_arn" {
  value = module.development[*].sns_deadletter
}