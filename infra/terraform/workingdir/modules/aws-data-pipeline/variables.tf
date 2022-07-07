variable "region" {
  type        = string
  description = "AWS region"
}

variable "prefix" {
  type        = string
  description = "Resource name prefix"
}

variable "environment" {
  type        = string
  description = "Environment for Deploy"
}

variable "stack_id" {
  type        = string
  description = "Random string"
}

variable "tags" {
  type        = map(string)
  description = "Default tags"
}

variable "deployment" {
  type        = string
  description = "Deployment ID"
}

variable "account_id" {
  type        = number
  description = "AWS Account ID"
}

variable "events" {
  type        = set(any)
  description = "Events to track"
}

variable "bucket_name" {
  type        = string
  description = "Name for S3 bucket"
  default     = "my-bucket"
}

variable "sqs_delay_seconds" {
  type        = number
  description = "The time in seconds that the delivery of all messages in the queue will be delayed"
  default     = 0
}

variable "sqs_max_message_size" {
  type        = number
  description = "The limit of how many bytes a message can contain before Amazon SQS rejects it"
  default     = 262144
}

variable "sqs_message_retention_seconds" {
  type        = number
  description = "The number of seconds Amazon SQS retains a message"
  default     = 345600
}

variable "sqs_receive_wait_time_seconds" {
  type        = number
  description = "The time for which a ReceiveMessage call will wait for a message to arrive (long polling) before returning"
  default     = 0
}

variable "sqs_deadletter_suffix" {
  type        = string
  description = "Suffix for the SQS responsible for processing other SQS deadletter events"
  default     = "sqs-deadletter"
}

variable "sqs_sns_deadletter_suffix" {
  type        = string
  description = "Suffix for the SQS responsible for processing SNS deadletter events"
  default     = "sns-deadletter"
}

variable "sqs_managed_sse_enabled" {
  type        = bool
  description = "Boolean to enable server-side encryption (SSE) of message content with SQS-owned encryption keys"
  default     = true
}

variable "lambda_suffix" {
  type        = string
  description = "Suffix for lambda scripts"
  default     = "worker"
}

variable "lambda_sqs_deadqueue_filename" {
  type        = string
  description = "Filename of your SQS Dead Queue script without extension"
  default     = "SQSDeadQueue"
}

variable "lambda_sns_deadqueue_filename" {
  type        = string
  description = "Filename of your SNS Dead Queue script without extension"
  default     = "SNSDeadQueue"
}

variable "lambda_handler_pattern_name" {
  type        = string
  description = "Name of your lambda handler"
  default     = "lambda_handler"
}
variable "lambda_origin_app_event_name" {
  type        = string
  description = "Name of the app you want to get data from"
  default     = "my-app"
}

variable "lambda_raw_data_s3_stage_name" {
  type        = string
  description = "How do you want to call the first ETL zone. Ex: raw, raw-zone, landing-zone, bronze, etc"
  default     = "raw"
}

variable "lambda_staging_data_s3_stage_name" {
  type        = string
  description = "How do you want to call the second ETL zone. Ex: staging, staging-zone, silver, etc"
  default     = "staging"
}

variable "lambda_log_s3_stage_name" {
  type        = string
  description = "How do you want to call the error logging zone"
  default     = "log"
}

variable "lambda_runtime" {
  type        = string
  description = "Runtime of your lambdas"
  default     = "python3.8"
}

variable "lambda_default_timeout" {
  type        = number
  description = "Max execution time for your lambdas before timeout. Is recommended to set this value based on capacity tests simulating your data flow"
  default     = 60
}

variable "lambda_default_concurrency" {
  type        = number
  description = "Number of concurrency for your lambdas. Is recommended to set this value based on capacity tests simulating your data flow"
  default     = 5
}

variable "lambda_zip_scripts_path" {
  type        = string
  description = "Path to your local zip packages, both lambda functions itself and layers"
}

variable "lambda_event_generator_zip_scripts_path" {
  type        = string
  description = "Path to your local zip packages, both lambda functions itself and layers"
}

variable "sns_arn" {
  type = string
  description = "SNS that will be used to receive random events from event generator"
}