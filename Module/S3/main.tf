data "aws_caller_identity" "current" {}

resource "aws_kms_key" "valohai_data_kms_key" {
  description         = "Valohai KMS key for default S3 bucket"
  enable_key_rotation = true

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "valohai-key-secrets",
    "Statement" : [
      {
        "Sid" : "Allow root to manage kms",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${var.aws_account_id}:root",
            "arn:aws:iam::${var.aws_account_id}:role/dev-valohai-iamr-master",
            "arn:aws:iam::${var.aws_account_id}:role/dev-valohai-iamr-worker",
            "arn:aws:iam::${var.aws_account_id}:role/dev-valohai-iamr-multipart"
          ]
        },
        "Action" : "kms:*",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_s3_bucket" "valohai_data" {
  #checkov:skip=CKV_AWS_144:S3 cross-region duplication
  #checkov:skip=CKV2_AWS_62:Ignore event notifications.
  #checkov:skip=CKV_AWS_18:Ensure the S3 bucket has access logging enabled
  bucket        = var.s3_bucket_name
  force_destroy = true

  logging {
    target_bucket = var.s3_logs_name
    target_prefix = "log/${var.s3_bucket_name}"
  }
}

resource "aws_s3_bucket_versioning" "valohai_data_versioning" {
  bucket = aws_s3_bucket.valohai_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "valohai_datablock_access" {
  bucket = aws_s3_bucket.valohai_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
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
    allowed_origins = [var.domain]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "valohai_bucket_sse" {
  bucket = aws_s3_bucket.valohai_data.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.valohai_data_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}


resource "aws_s3_bucket_lifecycle_configuration" "valohai_data_lifecycle" {
  bucket = aws_s3_bucket.valohai_data.id

  rule {
    id = "abort_incomplete_multipart_upload"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    status = "Enabled"
  }

  rule {
    id = "valohai_commit_snapshots"

    filter {
      prefix = "vcs/"
    }

    status = "Enabled"

    transition {
      days          = 30
      storage_class = "INTELLIGENT_TIERING"
    }
  }
}
