module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "2.14.1"

  bucket        = var.bucket_name
  acl           = "private"
  force_destroy = true

  logging = {
    target_bucket = "${module.log_bucket.s3_bucket_id}"
    target_prefix = ""
  }

  # S3 bucket-level Public Access Block configuration
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  tags = var.tags
}

module "s3_bucket_artifact" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "2.14.1"

  bucket        = "${var.bucket_name}-artifacts"
  acl           = "private"
  force_destroy = true

  # S3 bucket-level Public Access Block configuration
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  tags = var.tags
}

module "log_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "2.14.1"

  bucket                                = "${var.bucket_name}-logs"
  acl                                   = "log-delivery-write"
  force_destroy                         = true
  attach_elb_log_delivery_policy        = true
  attach_lb_log_delivery_policy         = true
  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  # S3 bucket-level Public Access Block configuration
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  tags = var.tags
}