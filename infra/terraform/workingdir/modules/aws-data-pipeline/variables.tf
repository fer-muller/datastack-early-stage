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