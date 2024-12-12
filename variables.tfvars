aws_profile    = "valohai-jordan"
aws_region     = "us-east-1"
aws_account_id = "767397824220"
ec2_key        = "/Users/jordancoaten/.valohai-key.pub" # path to your .pub key
lb_subnet_ids = [                   # Subnets for the ELB
  "subnet-0f97f9a6a41a2a6f0",
  "subnet-0ab97968d7c45b2fc"
]
roi_subnet_id = "subnet-0c46f06a1af307492" # Subnet for the Valohai app
db_subnet_ids = [
  "subnet-0c46f06a1af307492",
  "subnet-0a5e36b16a23758af"
]
worker_subnet_ids = [
  "subnet-0c46f06a1af307492",
  "subnet-0a5e36b16a23758af"
]

vpc_id           = "vpc-078bf49eff57047b9"
environment_name = "Valohai"
s3_bucket_name   = "valohai-data-jordan-s3"
s3_logs_name     = "valohai-data-logs-jordan"
domain           = "http://dev-valohai-alb-valohai-1648300628.us-east-1.elb.amazonaws.com"
certificate_arn  = ""
organization     = "TestOrg"
ami_id           = "ami-0dc651d908245c9d5" # AMI id from your Valohai contact
aws_instance_types = [
  "t3.small",
  "c5.2xlarge",
  "p3.2xlarge"
]
add_spot_instances      = false
aws_spot_instance_types = []