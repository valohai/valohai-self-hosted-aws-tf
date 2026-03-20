resource "aws_iam_role_policy" "valohai_worker_policy" {
  name = "${var.worker_role_prefix}iamp-worker"
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
      },
      {
        "Sid" : "KMSAccess",
        "Effect" : "Allow",
        "Action" : [
          "kms:GenerateDataKey",
          "kms:Decrypt",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role" "valohai_worker_role" {
  name        = "${var.worker_role_prefix}iamr-worker"
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
}

resource "aws_iam_instance_profile" "valohai_worker_profile" {
  name = "${var.worker_role_prefix}iamri-worker"
  role = aws_iam_role.valohai_worker_role.name
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.valohai_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
