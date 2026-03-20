terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# Security group for the environment setup machine
resource "aws_security_group" "valohai_sg_env_setup" {
  #checkov:skip=CKV2_AWS_5: "Ensure that Security Groups are attached to another resource"
  name        = "dev-valohai-sg-env-setup"
  description = "for Valohai Environmet Setup"

  vpc_id = var.vpc_id

  egress {
    description = "Allow outbound access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dev-valohai-sg-env-setup",
  }
}
