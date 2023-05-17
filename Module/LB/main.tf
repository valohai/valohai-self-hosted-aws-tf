data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "main" {}

resource "aws_lb" "valohai_lb" {
  name                       = "valohai-elb"
  load_balancer_type         = "application"
  internal                   = false
  subnets                    = var.lb_subnet_ids
  security_groups            = [aws_security_group.valohai_sg_lb.id]
  enable_deletion_protection = true
  drop_invalid_header_fields = true

  access_logs {
    bucket  = aws_s3_bucket.valohai_logs.bucket
    prefix  = "valohai-roi-lb"
    enabled = true
  }
}

resource "aws_s3_bucket" "valohai_logs" {
  bucket = "valohai-logs-${var.aws_account_id}"

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

resource "aws_s3_bucket_acl" "valohai_acl" {
  bucket = aws_s3_bucket.valohai_logs.id
  acl    = "log-delivery-write"
}

resource "aws_lb_target_group" "valohai_roi" {
  name     = "valohai-roilb-tg"
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
  load_balancer_arn = aws_lb.valohai_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.valohai_lb.id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  default_action {
    target_group_arn = aws_lb_target_group.valohai_roi.arn
    type             = "forward"
  }
}

resource "aws_lb_listener_certificate" "valohai_cert" {
  listener_arn    = aws_lb_listener.https.arn
  certificate_arn = var.certificate_arn
}

resource "aws_security_group" "valohai_sg_lb" {
  name        = "valohai_sg_lb"
  description = "for Valohai ELB"

  vpc_id = var.vpc_id

  ingress {
    description = "for ELB"
    from_port   = 443
    to_port     = 443
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

resource "aws_kms_key" "valohai_logs_kms_key" {
  description         = "Valohai KMS key for valohai-logs"
  enable_key_rotation = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "valohai_bucket_sse" {
  bucket = aws_s3_bucket.valohai_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.valohai_logs_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
