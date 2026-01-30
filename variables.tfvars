aws_profile    = "valohai-sandbox"
aws_region     = "us-east-1"
aws_account_id = ""
ec2_key        = ".valohai-key.pub" # path to your .pub key
lb_subnet_ids = [                   # Subnets for the ELB
  "",
  ""
]
roi_subnet_id = "" # Subnet for the Valohai app
db_subnet_ids = [
  "",
  ""
]
worker_subnet_ids = [
  "",
  ""
]

vpc_id           = ""
environment_name = "Valohai"
s3_bucket_name   = "valohai-data"
s3_logs_name     = "valohai-data-logs"
domain           = "https://test.valohai.com"
certificate_arn  = ""
organization     = "TestOrg"
ami_id           = "" # AMI id from your Valohai contact
aws_instance_types = [
  "t3.small",
  "c5.2xlarge",
  "p3.2xlarge"
]
add_spot_instances      = false
aws_spot_instance_types = []

enable_notebooks         = true # Set true for adding notebooks
notebook_certificate_arn = ""   # Certificate ARN from AWS
notebook_image           = ""   # Image URL for the notebook-proxy image
