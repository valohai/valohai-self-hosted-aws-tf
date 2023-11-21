data "aws_caller_identity" "current" {}

resource "aws_iam_role" "valohai_master_role" {
  name = "dev-valohai-iamr-master"

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
}

resource "aws_iam_instance_profile" "valohai_master_profile" {
  name = "dev-valohai-iami-master"
  role = aws_iam_role.valohai_master_role.name
}

resource "aws_iam_role_policy" "valohai_master_policy" {
  name = "dev-valohai-iamp-master"
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
        "Resource" : "arn:aws:iam::${var.aws_account_id}:role/dev-valohai-iamr-worker"
      },
      {
        "Sid" : "0",
        "Effect" : "Allow",
        "Action" : [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:DescribeParameters"
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
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:GetServiceSetting",
          "ssm:ResetServiceSetting",
          "ssm:UpdateServiceSetting"
        ],
        "Resource" : "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:servicesetting/ssm/managed-instance/default-instance-management-role"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "iam:PassRole"
        ],
        "Resource" : "arn:aws:iam::${var.aws_account_id}:role/service-role/AWSSystemsManagerDefaultEC2InstanceManagementRole",
        "Condition" : {
          "StringEquals" : {
            "iam:PassedToService" : [
              "ssm.amazonaws.com"
            ]
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:DescribeAssociation",
          "ssm:GetDeployablePatchSnapshotForInstance",
          "ssm:GetDocument",
          "ssm:DescribeDocument",
          "ssm:GetManifest",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:ListAssociations",
          "ssm:ListInstanceAssociations",
          "ssm:PutInventory",
          "ssm:PutComplianceItems",
          "ssm:PutConfigurePackageResult",
          "ssm:UpdateAssociationStatus",
          "ssm:UpdateInstanceAssociationStatus",
          "ssm:UpdateInstanceInformation"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2messages:AcknowledgeMessage",
          "ec2messages:DeleteMessage",
          "ec2messages:FailMessage",
          "ec2messages:GetEndpoint",
          "ec2messages:GetMessages",
          "ec2messages:SendReply"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:StartSession"
        ],
        "Resource" : [
          "arn:aws:ec2:${var.aws_region}:${var.aws_account_id}:instance/*",
          "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:document/SSM-SessionManagerRunShell"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:TerminateSession",
          "ssm:ResumeSession"
        ],
        "Resource" : [
          "arn:aws:ssm:*:*:session/*"
        ]
      }
    ]
  })
}
