data "aws_caller_identity" "current" {}

resource "aws_kms_key" "valohai_kms_key" {
  description         = "Valohai KMS key for secrets"
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
          ]
        },
        "Action" : "kms:*",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_kms_alias" "valohai_kms_alias" {
  target_key_id = aws_kms_key.valohai_kms_key.key_id
}

resource "random_password" "repo_private_key" {
  length  = 32
  special = false
}

resource "aws_ssm_parameter" "repo_private_key" {
  name        = "dev-valohai-ssm-repo"
  type        = "SecureString"
  description = "Secure repository key for Valohai"
  value       = random_password.repo_private_key.result
  key_id      = aws_kms_key.valohai_kms_key.id
}

resource "random_password" "secret_key" {
  length  = 32
  special = false
}

resource "aws_ssm_parameter" "secret_key" {
  name        = "dev-valohai-ssm-secret"
  type        = "SecureString"
  description = "Secure secret key for Valohai"
  value       = random_password.secret_key.result
  key_id      = aws_kms_key.valohai_kms_key.id
}

resource "random_password" "jwt_key" {
  length  = 32
  special = false
}

resource "aws_ssm_parameter" "jwt_key" {
  name        = "dev-valohai-ssm-jwt"
  type        = "SecureString"
  description = "Secure jwt key for Valohai"
  value       = random_password.jwt_key.result
  key_id      = aws_kms_key.valohai_kms_key.id
}

# Get the AMI for roi instance
data "aws_ami" "valohai" {
  most_recent = true

  filter {
    name   = "name"
    values = ["valohai-roi-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["910181886844"]
}

# Load public key
resource "aws_key_pair" "valohai_roi_key" {
  key_name   = "dev-valohai-key-valohai"
  public_key = file(var.ec2_key)

  tags = {
    Name = "dev-valohai-key-valohai",
  }
}

# Valohai roi instance
resource "aws_instance" "valohai_roi" {
  ami                    = data.aws_ami.valohai.id
  instance_type          = "m5.xlarge"
  key_name               = aws_key_pair.valohai_roi_key.id
  vpc_security_group_ids = [aws_security_group.valohai_sg_roi.id]
  subnet_id              = var.roi_subnet_id
  iam_instance_profile   = "dev-valohai-iami-master"
  monitoring             = true
  ebs_optimized          = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  root_block_device {
    volume_type = "gp2"
    volume_size = 32
    encrypted   = true
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = aws_instance.valohai_roi.public_ip
    private_key = file(var.roi_key)
  }

  tags = {
    Name = "dev-valohai-ec2-roi",
  }

  user_data = <<-EOF
    #!/bin/bash

    sudo systemctl stop roi
    export ROI_AUTO_MIGRATE=true

    export REPO_PRIVATE_KEY=`aws ssm get-parameter --name ${aws_ssm_parameter.repo_private_key.name} --with-decryption | sed -n 's|.*"Value": *"\([^"]*\)".*|\1|p'`
    export SECRET_KEY=`aws ssm get-parameter --name ${aws_ssm_parameter.secret_key.name} --with-decryption | sed -n 's|.*"Value": *"\([^"]*\)".*|\1|p'`
    export JWT_KEY=`aws ssm get-parameter --name ${aws_ssm_parameter.jwt_key.name} --with-decryption | sed -n 's|.*"Value": *"\([^"]*\)".*|\1|p'`

    sed -i "s|URL_BASE=|URL_BASE=${var.domain}|" /etc/roi.config
    sed -i "s|AWS_REGION=|AWS_REGION=${var.region}|" /etc/roi.config
    sed -i "s|AWS_S3_BUCKET_NAME=|AWS_S3_BUCKET_NAME=${var.s3_bucket_name}|" /etc/roi.config
    sed -i "s|AWS_S3_MULTIPART_UPLOAD_IAM_ROLE=|AWS_S3_MULTIPART_UPLOAD_IAM_ROLE=arn:aws:iam::${var.aws_account_id}:role/dev-valohai-iamr-multipart|" /etc/roi.config
    sed -i "s|CELERY_BROKER=|CELERY_BROKER=redis://${var.redis_url}:6379|" /etc/roi.config
    sed -i "s|DATABASE_URL=|DATABASE_URL=psql://roi:${var.db_password}@${var.db_url}:5432/valohairoidb|" /etc/roi.config
    sed -i "s|PLATFORM_LONG_NAME=|PLATFORM_LONG_NAME=${var.environment_name}|" /etc/roi.config
    sed -i "s|REPO_PRIVATE_KEY_SECRET=|REPO_PRIVATE_KEY_SECRET=$REPO_PRIVATE_KEY|" /etc/roi.config
    sed -i "s|SECRET_KEY=|SECRET_KEY=$SECRET_KEY|" /etc/roi.config
    sed -i "s|STATS_JWT_KEY=|STATS_JWT_KEY=$JWT_KEY|" /etc/roi.config

    sudo systemctl start roi

    sudo docker run -it --env-file=/etc/roi.config valohai/roi:latest python manage.py migrate --mode dev
    sudo docker run -it --env-file=/etc/roi.config valohai/roi:latest python manage.py roi_init --mode dev

    sudo snap start amazon-ssm-agent
    EOF
}

resource "aws_security_group" "valohai_sg_roi" {
  name        = "dev-valohai-sg-roi"
  description = "for Valohai Roi"

  vpc_id = var.vpc_id

  ingress {
    description     = "for ELB Access "
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [var.lb_sg, aws_security_group.valohai_sg_workers.id]
  }

  egress {
    description = "Allow outbound access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dev-valohai-sg-roi",
  }
}

resource "aws_lb_target_group_attachment" "valohai_roi" {
  target_group_arn = var.lb_target_group_id
  target_id        = aws_instance.valohai_roi.id
  port             = 8000
}

resource "aws_security_group" "valohai_sg_workers" {
  #checkov:skip=CKV2_AWS_5:Ensure security groups are attached to another resource
  name        = "dev-valohai-sg-workers"
  description = "for Valohai workers"

  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound access"
  }

  tags = {
    Name = "dev-valohai-sg-workers",
  }
}
