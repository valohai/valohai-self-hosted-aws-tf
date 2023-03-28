terraform {

  required_version = "1.4.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "valohai_data" {
  bucket        = "valohai-data-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "valohai_datablock_access" {
  bucket = aws_s3_bucket.valohai_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "valohai_acl" {
  bucket = aws_s3_bucket.valohai_data.id
  acl    = "private"
}

resource "aws_s3_bucket_cors_configuration" "valohai_cors" {
  bucket = aws_s3_bucket.valohai_data.id

  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }

  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["POST"]
    allowed_origins = ["https://app.valohai.com"]
    max_age_seconds = 3000
  }

}