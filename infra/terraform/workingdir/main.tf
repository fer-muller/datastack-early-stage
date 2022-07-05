locals {
  # TODO: update the prefix according to your project
  prefix      = "data-project-name"
  stack_id    = random_string.stack.id
  environment = "development"
  deployment  = "${local.prefix}-${local.environment}-${local.stack_id}"
  tags = {
    Environment = local.environment
    Deployment  = local.deployment
    StackId     = local.stack_id
    Terraform   = "true"
    CostCenter  = "Data"
    App         = "app-data-pipeline"
    Service     = "data-pipeline"
  }
  account_id = data.aws_caller_identity.current.account_id
}

provider "aws" {
  region = var.region
  #Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}
################################################################################
# Extra resources
################################################################################
resource "random_string" "stack" {
  length  = 8
  numeric  = true
  lower   = true
  upper   = false
  special = false
}

data "aws_caller_identity" "current" {}
################################################################################
# Development environment
################################################################################
module "development" {
  source = "./modules/environments/development"

  #count = local.environment == "development" ? 1 : 0

  region                                 = var.region
  environment                            = local.environment
  prefix                                 = local.prefix
  stack_id                               = local.stack_id
  tags                                   = local.tags
  deployment                             = local.deployment
  account_id                             = local.account_id
  # TO DO: Update events according to your project
  events                                 = ["login", "registration", "newPayment"]
  etl_batch_size                         = 50
  etl_maximum_batching_window_in_seconds = 300
}