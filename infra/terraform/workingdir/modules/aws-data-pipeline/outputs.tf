output "main_bucket_name" {
  value = module.s3_bucket.s3_bucket_id
}

output "main_bucket_arn" {
  value = module.s3_bucket.s3_bucket_arn
}