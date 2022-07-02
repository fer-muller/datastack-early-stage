module "aws_data_pipeline" {
  # GENERAL VARIABLES
  source      = "../../aws-data-pipeline"
  environment = var.environment
  deployment  = var.deployment
  region      = var.region
  prefix      = var.prefix
  stack_id    = var.stack_id
  account_id  = var.account_id
  tags        = var.tags
  events      = var.events

  #S3 VARIABLES
  bucket_name = var.deployment
}