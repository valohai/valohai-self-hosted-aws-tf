
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "valohai_data_multipart" {
  name        = "dev-valohai-iamr-multipart"
  description = "Allows users to save files over 5GB from their executions"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${var.aws_account_id}:role/dev-valohai-iamr-master"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "valohai_multipart_policy" {
  name = "dev-valohai-iamp-multipart"
  role = aws_iam_role.valohai_data_multipart.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "MultipartAccess",
        "Effect" : "Allow",
        "Action" : [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:ListBucketVersions",
          "s3:ListMultipartUploadParts",
          "s3:PutObject"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      }
    ]
  })
}
