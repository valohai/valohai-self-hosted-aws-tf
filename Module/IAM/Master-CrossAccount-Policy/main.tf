# This module adds AssumeRole permission to the control plane's IAM Master role
# to allow it to assume the worker account's IAM Master role
# Only created when workers are in a different account

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_iam_role_policy" "master_assume_worker_role" {
  name = "${var.resource_name_prefix}policy-assume-master-${var.worker_account_id}"
  role = "${var.control_plane_resource_name_prefix}iamr-master" # Control plane master role

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowAssumeWorkerAccountMasterRole"
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = "arn:aws:iam::${var.worker_account_id}:role/${var.resource_name_prefix}iamr-master"
      }
    ]
  })
}
