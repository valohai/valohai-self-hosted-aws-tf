terraform {

  required_version = "1.4.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
}

data "aws_caller_identity" "current" {}

resource "random_password" "repo_private_key" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "valohai_repo_key" {
  name_prefix = "ValohaiRepoKey-"

  tags = {
    valohai = 1
  }
}

resource "aws_secretsmanager_secret_version" "valohai_repo_key_version" {
  secret_id     = aws_secretsmanager_secret.valohai_repo_key.id
  secret_string = random_password.repo_private_key.result
}

resource "random_password" "secret_key" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "valohai_secret_key" {
  name_prefix = "ValohaiSecretKey-"

  tags = {
    valohai = 1
  }
}

resource "aws_secretsmanager_secret_version" "valohai_secret_key_version" {
  secret_id     = aws_secretsmanager_secret.valohai_secret_key.id
  secret_string = random_password.secret_key.result
}

resource "random_password" "jwt_key" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "valohai_jwt_key" {
  name_prefix = "ValohaiJWTKey-"

  tags = {
    valohai = 1
  }
}

resource "aws_secretsmanager_secret_version" "valohai_jwt_key_version" {
  secret_id     = aws_secretsmanager_secret.valohai_jwt_key.id
  secret_string = random_password.jwt_key.result
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

  owners = ["910181886844"] # Valohai Staging
}

# Load public key
resource "aws_key_pair" "valohai_roi_key" {
  key_name   = "valohai_${var.region}"
  public_key = file(var.ec2_key)

  tags = {
    Name    = "valohai_roi",
    valohai = 1
  }
}

# Valohai roi instance
resource "aws_instance" "valohai_roi" {
  ami                    = data.aws_ami.valohai.id
  instance_type          = "m5.xlarge"
  key_name               = aws_key_pair.valohai_roi_key.id
  vpc_security_group_ids = var.roi_security_group_ids
  subnet_id              = var.roi_subnet_id
  iam_instance_profile   = "ValohaiMasterInstanceProfile"

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_type = "gp2"
    volume_size = 32
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = aws_instance.valohai_roi.public_ip
    private_key = file(var.roi_key)
  }

  tags = {
    Name    = "valohai_roi",
    valohai = 1
  }

  user_data = <<-EOF
    #!/bin/bash
    
    sudo systemctl stop roi
    export ROI_AUTO_MIGRATE=true
    
    export REPO_PRIVATE_KEY=`aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.valohai_repo_key.name} --region ${var.region}| sed -n 's|.*"SecretString": *"\([^"]*\)".*|\1|p'`
    export SECRET_KEY=`aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.valohai_secret_key.name} --region ${var.region}| sed -n 's|.*"SecretString": *"\([^"]*\)".*|\1|p'`
    export JWT_KEY=`aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.valohai_jwt_key.name} --region ${var.region}| sed -n 's|.*"SecretString": *"\([^"]*\)".*|\1|p'`

    sed -i "s|URL_BASE=|URL_BASE=http://`curl http://169.254.169.254/latest/meta-data/public-ipv4`|" /etc/roi.config
    sed -i "s|AWS_REGION=|AWS_REGION=${var.region}|" /etc/roi.config
    sed -i "s|AWS_S3_BUCKET_NAME=|AWS_S3_BUCKET_NAME=valohai-data-${data.aws_caller_identity.current.account_id}|" /etc/roi.config
    sed -i "s|AWS_S3_MULTIPART_UPLOAD_IAM_ROLE=|AWS_S3_MULTIPART_UPLOAD_IAM_ROLE=arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ValohaiS3MultipartRole|" /etc/roi.config
    sed -i "s|CELERY_BROKER=|CELERY_BROKER=redis://${var.redis_url}:6379|" /etc/roi.config
    sed -i "s|DATABASE_URL=|DATABASE_URL=psql://roi:${var.db_password}@${var.db_url}:5432/valohairoidb|" /etc/roi.config
    sed -i "s|PLATFORM_LONG_NAME=|PLATFORM_LONG_NAME=${var.environment_name}|" /etc/roi.config
    sed -i "s|REPO_PRIVATE_KEY_SECRET=|REPO_PRIVATE_KEY_SECRET=$REPO_PRIVATE_KEY|" /etc/roi.config
    sed -i "s|SECRET_KEY=|SECRET_KEY=$SECRET_KEY|" /etc/roi.config
    sed -i "s|STATS_JWT_KEY=|STATS_JWT_KEY=$JWT_KEY|" /etc/roi.config

    sudo systemctl start roi

    sudo docker run -it --env-file=/etc/roi.config valohai/roi:latest python manage.py roi_init --mode dev
    
    EOF
}

resource "aws_lb" "valohai_elb" {
  name               = "valohai-elb"
  load_balancer_type = "application"
  internal           = false
  subnets            = var.elb_subnet_ids
  security_groups    = var.elb_security_group_ids
}

resource "aws_lb_target_group" "valohai_roi" {
  name     = "valohai-roilb-tg"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    enabled = true
    matcher = "200,202"
    path = "/healthz"
  }
}

resource "aws_lb_target_group_attachment" "valohai_roi" {
  target_group_arn = aws_lb_target_group.valohai_roi.arn
  target_id        = aws_instance.valohai_roi.id
  port             = 8000
}

resource "aws_lb_listener" "valohai_elb" {
  load_balancer_arn = aws_lb.valohai_elb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.valohai_roi.arn
  }
}
