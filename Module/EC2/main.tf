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
#data "aws_ami" "valohai" {
#  most_recent = true
#
#  filter {
#    name   = "name"
#    values = ["valohai-roi-*"]
#  }
#
#  filter {
#    name   = "virtualization-type"
#    values = ["hvm"]
#  }
#
#  owners = ["635691382966"]
#}

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
  ami                    = var.ami_id
  instance_type          = "m5.xlarge"
  key_name               = aws_key_pair.valohai_roi_key.id
  vpc_security_group_ids = [aws_security_group.valohai_sg_roi.id]
  subnet_id              = var.roi_subnet_id
  iam_instance_profile   = "dev-valohai-iami-master"
  monitoring             = true
  ebs_optimized          = true
  user_data              = templatefile("${path.module}/config/user_data.sh", {
    repo_private_key     = aws_ssm_parameter.repo_private_key.name
    secret_key           = aws_ssm_parameter.secret_key.name
    jwt_key              = aws_ssm_parameter.jwt_key.name
    url_base             = var.domain
    region               = var.region
    s3_bucket            = var.s3_bucket_name
    s3_kms_key           = var.s3_kms_key
    aws_account_id       = var.aws_account_id
    redis_url            = var.redis_url
    db_password          = var.db_password
    db_url               = var.db_url
    environment_name     = var.environment_name
    module_path          = "${path.module}"
    vpc_id               = var.vpc_id
    organization         = var.organization
    aws_instance_types   = indent(2,yamlencode(var.aws_instance_types))
    aws_spot_instance_types   = var.add_spot_instances ? indent(2,yamlencode(formatlist("%s.spot", var.aws_spot_instance_types))) : ""
  })
  user_data_replace_on_change = true

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

  tags = {
    Name = "dev-valohai-ec2-roi",
  }

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
