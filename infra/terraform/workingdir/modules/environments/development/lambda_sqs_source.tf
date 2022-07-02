resource "aws_lambda_event_source_mapping" "sqs_worker" {
  count                              = length(var.events)
  event_source_arn                   = module.aws_data_pipeline.sqs_etl_arns_list[count.index]
  function_name                      = module.aws_data_pipeline.lambda_etl_arn_list[count.index]
  batch_size                         = var.etl_batch_size
  maximum_batching_window_in_seconds = var.etl_maximum_batching_window_in_seconds
}

resource "aws_lambda_event_source_mapping" "sqs_deadletter" {
  event_source_arn                   = module.aws_data_pipeline.sqs_deadletter
  function_name                      = module.aws_data_pipeline.lambda_sqs_deadletter_name
  batch_size                         = var.etl_batch_size
  maximum_batching_window_in_seconds = var.etl_maximum_batching_window_in_seconds
}

resource "aws_lambda_event_source_mapping" "sns_deadletter" {
  event_source_arn                   = module.aws_data_pipeline.sns_deadletter
  function_name                      = module.aws_data_pipeline.lambda_sns_deadletter_name
  batch_size                         = var.etl_batch_size
  maximum_batching_window_in_seconds = var.etl_maximum_batching_window_in_seconds
}