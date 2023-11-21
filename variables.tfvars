aws_profile    = "valohai-sandbox"
aws_region     = "us-east-1"
aws_account_id = "450886142693"
ec2_key        = ".valohai-key.pub" # path to your .pub key
lb_subnet_ids = [                   # Subnets for the ELB
  "subnet-09fa71506c5274edf",
  "subnet-0ef2e899c53ce8e3f"
]
roi_subnet_id = "subnet-0876140165953bf66" # Subnet for the Valohai app
db_subnet_ids = [
  "subnet-0876140165953bf66",
  "subnet-095202b0a4f855773"
]
worker_subnet_ids = [
  "subnet-0876140165953bf66",
  "subnet-095202b0a4f855773"
]
vpc_id           = "vpc-066122736a3c21fc2"
environment_name = "Valohai"
s3_bucket_name   = "valohai-data"
s3_logs_name     = "valohai-data-logs"
domain           = "https://test.valohai.com"
certificate_arn  = ""
organization     = "TestOrg"
aws_instance_types = [
    "t3.small",
    "c5.xlarge",
    "p3.2xlarge"
]