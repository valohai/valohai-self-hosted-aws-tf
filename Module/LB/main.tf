data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "main" {}

resource "aws_lb" "valohai_lb" {
  #checkov:skip=CKV2_AWS_28:Ensure public facing ALB are protected by WAF
  #checkov:skip=CKV2_AWS_20:Allow using HTTP only on ALB for sample purposes
  name                       = "dev-valohai-alb-valohai"
  load_balancer_type         = "application"
  internal                   = false
  subnets                    = var.lb_subnet_ids
  security_groups            = [aws_security_group.valohai_sg_lb.id]
  enable_deletion_protection = true
  drop_invalid_header_fields = true

  access_logs {
    bucket  = aws_s3_bucket.valohai_logs.bucket
    prefix  = "lb-valohai-roi"
    enabled = true
  }
}

resource "aws_s3_bucket" "valohai_logs" {
  #checkov:skip=CKV_AWS_144:S3 cross-region duplication
  #checkov:skip=CKV2_AWS_62:Ignore event notifications.
  #checkov:skip=CKV_AWS_18:Ensure the S3 bucket has access logging enabled
  #checkov:skip=CKV_AWS_145:Don't require KMS encrypt for ALB logs
  #checkov:skip=CKV_AWS_19:Don't encrypt logs at rest
  bucket = var.s3_logs_name

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "valohai_datablock_access" {
  bucket = aws_s3_bucket.valohai_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_lb_target_group" "valohai_roi" {
  port     = 8000
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    enabled = true
    matcher = "200,202"
    path    = "/healthz"
  }
}

resource "aws_lb_listener" "http" {
  #checkov:skip=CKV_AWS_2:Don't ensure protocol is HTTPS for example purposes
  #checkov:skip=CKV_AWS_103:Don't redirect HTTP to HTTPS for example purposes
  load_balancer_arn = aws_lb.valohai_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.valohai_roi.arn
  }
}

resource "aws_security_group" "valohai_sg_lb" {
  #checkov:skip=CKV_AWS_260:Allow port 80 for example purposes
  name        = "dev-valohai-sg-alb"
  description = "for Valohai ELB"

  vpc_id = var.vpc_id

  ingress {
    description = "for ELB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "valohai_sg_lb",
  }
}

resource "aws_s3_bucket_policy" "valohai_bucket_policy" {
  bucket = aws_s3_bucket.valohai_logs.id
  policy = data.aws_iam_policy_document.s3_bucket_lb_write.json
}

data "aws_iam_policy_document" "s3_bucket_lb_write" {
  policy_id = "ValohaiS3BucketLBLogs"

  statement {
    actions = [
      "s3:PutObject",
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.valohai_logs.arn}/*",
    ]

    principals {
      identifiers = [data.aws_elb_service_account.main.arn]
      type        = "AWS"
    }
  }

  statement {
    actions = [
      "s3:PutObject"
    ]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.valohai_logs.arn}/*"]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }

  statement {
    actions = [
      "s3:GetBucketAcl"
    ]
    effect    = "Allow"
    resources = [aws_s3_bucket.valohai_logs.arn]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "valohai_data_lifecycle" {
  bucket = aws_s3_bucket.valohai_logs.id

  rule {
    id = "abort_incomplete_multipart_upload"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    status = "Enabled"
  }

  rule {
    id = "valohai_commit_snapshots"

    status = "Enabled"

    transition {
      days          = 30
      storage_class = "ONEZONE_IA"
    }
  }
}
