output "main_bucket_name" {
  value = module.s3_bucket.s3_bucket_id
}

output "main_bucket_arn" {
  value = module.s3_bucket.s3_bucket_arn
}

output "sqs_etl_arns" {
  value = {
    for i, j in aws_sqs_queue.etl_queues : i => j.arn
  }
}

output "sqs_etl_arns_list" {
  value = [for i in aws_sqs_queue.etl_queues : i.arn]
}

output "sqs_deadletter" {
  value = aws_sqs_queue.etl_dead_queue.arn
}

output "sns_deadletter" {
  value = aws_sqs_queue.sns_dead_queue.arn
}

output "lambda_etl_arn" {
  value = {
    for i, j in aws_lambda_function.sqs_worker : i => j.arn
  }
}

output "lambda_etl_arn_list" {
  value = [for i in aws_lambda_function.sqs_worker : i.arn]
}

output "lambda_sqs_etl_arns" {
  value = {
    for i, j in aws_lambda_function.sqs_worker : j.arn => aws_sqs_queue.etl_queues[i].arn
  }
}

output "lambda_sqs_deadletter" {
  value = aws_lambda_function.sqs_deadletter.arn
}

output "lambda_sqs_deadletter_name" {
  value = aws_lambda_function.sqs_deadletter.function_name
}

output "lambda_sns_deadletter" {
  value = aws_lambda_function.sns_deadletter.arn
}

output "lambda_sns_deadletter_name" {
  value = aws_lambda_function.sns_deadletter.function_name
}