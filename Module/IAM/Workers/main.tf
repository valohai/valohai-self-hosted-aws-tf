terraform {

  required_version = "1.4.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

resource "aws_iam_role_policy" "valohai_worker_policy" {
  name = "ValohaiWorkerPolicy"
  role = aws_iam_role.valohai_worker_role.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "autoscaling:SetInstanceProtection",
        "Resource" : "*",
        "Effect" : "Allow",
        "Sid" : "1"
      },
      {
        "Action" : "ec2:DescribeInstances",
        "Resource" : "*",
        "Effect" : "Allow",
        "Sid" : "2"
      }
    ]
  })
}

resource "aws_iam_role" "valohai_worker_role" {
  name        = "ValohaiWorkerRole"
  description = "A Valohai role that is by default assigned to all launched EC2 instances"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    valohai = 1,
  }
}

resource "aws_iam_instance_profile" "valohai_worker_profile" {
  name = "ValohaiWorkerProfile"
  role = aws_iam_role.valohai_worker_role.name
}