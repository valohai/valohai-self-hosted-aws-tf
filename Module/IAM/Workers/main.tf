resource "aws_iam_role_policy" "valohai_worker_policy" {
  name = "dev-valohai-iamp-worker"
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
  name        = "dev-valohai-iamr-worker"
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
  name = "dev-valohai-iamri-worker"
  role = aws_iam_role.valohai_worker_role.name
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.valohai_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
