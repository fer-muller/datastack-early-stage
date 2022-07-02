output "main_bucket_name" {
  value = module.sqs_lambda_s3.main_bucket_name
}

output "main_bucket_arn" {
  value = module.sqs_lambda_s3.main_bucket_arn
}