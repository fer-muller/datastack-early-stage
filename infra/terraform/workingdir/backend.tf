# See https://www.terraform.io/cli/config/config-file#credentials
terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    # TODO: update to Terraform Cloud organization name.
    organization = "terraform-test234543"

    workspaces {
      prefix = "data-"
    }
  }
}