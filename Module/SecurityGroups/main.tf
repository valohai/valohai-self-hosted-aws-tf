terraform {

  required_version = "1.4.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
resource "aws_security_group" "valohai_sg_roi" {
  name        = "valohai_sg_roi"
  description = "for Valohai Roi"

  vpc_id = var.vpc_id

  ingress {
    description = "for SSH debugging"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    description = "for SSH debugging"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "valohai_sg_roi",
    valohai = 1
  }
}

resource "aws_security_group" "valohai_sg_workers" {
  name        = "valohai_sg_workers"
  description = "for Valohai workers"

  vpc_id = var.vpc_id

  ingress {
    description = "for SSH debugging"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "valohai_sg_workers",
    valohai = 1
  }
}

resource "aws_security_group" "valohai_sg_queue" {
  name        = "valohai_sg_queue"
  description = "for Valohai Queue"

  vpc_id = var.vpc_id

  ingress {
    description     = "for Redis"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.valohai_sg_roi.id, aws_security_group.valohai_sg_workers.id]
  }

  tags = {
    Name    = "valohai_sg_queue",
    valohai = 1
  }
}