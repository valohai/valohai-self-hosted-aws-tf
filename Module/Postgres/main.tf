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

resource "aws_secretsmanager_secret" "valohai_redis_secret" {
  name_prefix = "ValohaiRedisSecret-"

  tags = {
    valohai = 1
  }
}

resource "random_password" "password" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret_version" "valohai_redis_secret_1" {
  secret_id     = aws_secretsmanager_secret.valohai_redis_secret.id
  secret_string = random_password.password.result
}

resource "aws_db_subnet_group" "valohai_roidb_subnet" {
  name       = "valohai_roidb_subnet"
  subnet_ids = var.db_subnet_ids

}

resource "aws_security_group" "valohai_roidb_sg" {
  name        = "valohai_roidb_sg"
  description = "Valohai RDS security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.security_group_ids
  }
}

resource "aws_db_instance" "valohai_roidb" {
  identifier = "valohai-roidb"

  engine              = "postgres"
  engine_version      = "14.2"
  instance_class      = "db.m5.large"
  allocated_storage   = 20
  storage_encrypted   = false
  multi_az            = true
  publicly_accessible = false
  port                = "5432"

  db_name  = "valohairoidb"
  username = "roi"
  password = random_password.password.result

  vpc_security_group_ids = [aws_security_group.valohai_roidb_sg.id]
  db_subnet_group_name   = "valohai_roidb_subnet"

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  backup_retention_period   = 3
  skip_final_snapshot       = true
  final_snapshot_identifier = "valohai-roidb-latest"
  deletion_protection       = false

  tags = { valohai = "1" }

  depends_on = [
    aws_db_subnet_group.valohai_roidb_subnet
  ]

}
