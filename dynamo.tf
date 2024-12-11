resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  #checkov:skip=CKV_AWS_28:Ensure Dynamodb point in time recovery (backup) is enabled
  #checkov:skip=CKV_AWS_119:Ensure DynamoDB Tables are encrypted using a KMS Customer Managed CMK
  #checkov:skip=CKV2_AWS_16:Ensure that Auto Scaling is enabled on your DynamoDB tables
  name           = "terraform-state-lock-dynamo"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }
}
