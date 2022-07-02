variable "region" {
  type        = string
  description = "AWS region"
}

variable "environment" {
  type        = string
  description = "Environment for Deploy"
}

variable "prefix" {
  type        = string
  description = "Resource name prefix"
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

variable "etl_batch_size" {
  type        = number
  description = "Number of events you want your SQS to hold before calling a lambda"
  default     = 50
}

variable "etl_maximum_batching_window_in_seconds" {
  type        = number
  description = "Number in seconds you want your SQS to hold before calling a lambda"
  default     = 300
}