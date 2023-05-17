data "aws_caller_identity" "current" {}

data "aws_vpc" "valohai_vpc" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

resource "aws_kms_key" "valohai_db_kms_key" {
  description         = "Valohai KMS key for DB"
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
            "arn:aws:iam::${var.aws_account_id}:root"
          ]
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "Allow Valohai master to read",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${var.aws_account_id}:role/ValohaiMaster",
          ]
        },
        "Action" : ["kms:Decrypt", "kms:DescribeKey"],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_kms_alias" "valohai_kms_alias" {
  target_key_id = aws_kms_key.valohai_db_kms_key.key_id
  name          = "alias/valohai-db-alias"
}

resource "random_password" "password" {
  length  = 32
  special = false
}

resource "aws_ssm_parameter" "db_password" {
  name        = "valohai-db-password"
  type        = "SecureString"
  description = "Password for Valohai roidb"
  value       = random_password.password.result
  key_id      = aws_kms_key.valohai_db_kms_key.id
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
    description = "for Redis"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.valohai_vpc.cidr_block]
  }
}

resource "aws_db_parameter_group" "valohai_roidb" {
  name   = "valohai-roidb-pg"
  family = "postgres14"

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1"
  }
}

resource "aws_iam_role" "valohai_rds_monitoring_role" {
  name = "ValohaiRdsMonitoringRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"]

  tags = {
    Name = "ValohaiRdsMonitoringRole"
  }
}

resource "aws_db_instance" "valohai_roidb" {
  identifier = "valohai-roidb"

  engine                              = "postgres"
  engine_version                      = "14.3"
  instance_class                      = "db.m5.large"
  allocated_storage                   = 20
  storage_encrypted                   = true
  multi_az                            = true
  publicly_accessible                 = false
  port                                = "5432"
  auto_minor_version_upgrade          = true
  monitoring_interval                 = 10
  monitoring_role_arn                 = aws_iam_role.valohai_rds_monitoring_role.arn
  iam_database_authentication_enabled = true
  enabled_cloudwatch_logs_exports     = ["postgresql", "upgrade"]
  copy_tags_to_snapshot               = true

  parameter_group_name = aws_db_parameter_group.valohai_roidb.name

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
  deletion_protection       = true

  depends_on = [
    aws_db_subnet_group.valohai_roidb_subnet
  ]

}
