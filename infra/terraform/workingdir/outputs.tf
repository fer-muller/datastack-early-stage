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