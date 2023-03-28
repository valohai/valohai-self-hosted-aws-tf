terraform {

  required_version = "1.4.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

data "aws_caller_identity" "current" {}
resource "aws_iam_role" "valohai_master_role" {
  name = "ValohaiMaster"

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

resource "aws_iam_instance_profile" "valohai_master_profile" {
  name = "ValohaiMasterInstanceProfile"
  role = aws_iam_role.valohai_master_role.name
}

resource "aws_iam_role_policy" "valohai_master_policy" {
  name = "ValohaiMasterPolicy"
  role = aws_iam_role.valohai_master_role.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "2",
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeInstances",
          "ec2:DescribeVpcs",
          "ec2:DescribeKeyPairs",
          "ec2:DescribeImages",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:DescribeInstanceAttribute",
          "ec2:DescribeRouteTables",
          "ec2:DescribeInternetGateways",
          "ec2:CreateTags",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeScalingActivities"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowUpdatingSpotLaunchTemplates",
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateLaunchTemplate",
          "ec2:CreateLaunchTemplateVersion",
          "ec2:ModifyLaunchTemplate",
          "ec2:RunInstances",
          "ec2:RebootInstances",
          "autoscaling:UpdateAutoScalingGroup",
          "autoscaling:CreateOrUpdateTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:CreateAutoScalingGroup"
        ],
        "Resource" : "*",
        "Condition" : {
          "ForAllValues:StringEquals" : {
            "aws:ResourceTag/Valohai" : "1"
          }
        }
      },
      {
        "Sid" : "ServiceLinkedRole",
        "Effect" : "Allow",
        "Action" : "iam:CreateServiceLinkedRole",
        "Resource" : "arn:aws:iam::*:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
      },
      {
        "Sid" : "4",
        "Effect" : "Allow",
        "Action" : [
          "iam:PassRole",
          "iam:GetRole"
        ],
        "Resource" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ValohaiWorkerRole"
      },
      {
        "Sid" : "0",
        "Effect" : "Allow",
        "Condition" : {
          "StringEquals" : {
            "secretsmanager:ResourceTag/valohai" : "1"
          }
        },
        "Action" : [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ],
        "Resource" : "*"
      },
      {
        "Action" : "secretsmanager:GetRandomPassword",
        "Resource" : "*",
        "Effect" : "Allow",
        "Sid" : "1"
      },
      {
        "Effect" : "Allow",
        "Action" : "s3:*",
        "Resource" : [
          "arn:aws:s3:::valohai-data-${data.aws_caller_identity.current.account_id}",
          "arn:aws:s3:::valohai-data-${data.aws_caller_identity.current.account_id}/*"
        ]
      }
    ]
  })
}

