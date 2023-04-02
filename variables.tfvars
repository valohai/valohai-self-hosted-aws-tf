aws_profile = #"valohai-sandbox" # your AWS profile (under ~/.aws/credentials) 
region      = #"us-east-1"       # e.g. eu-central-1
ec2_key     = #".valohai.pub"    # path to your .pub key
elb_subnet_ids = [              # Subnets for the ELB
  #"subnet-09fa71506c5274edf",
  #"subnet-0ef2e899c53ce8e3f"
]
roi_subnet_id = #"subnet-0876140165953bf66" # Subnet for the Valohai app
db_subnet_ids = [
  #"subnet-0876140165953bf66",
  #"subnet-095202b0a4f855773"
]
worker_subnet_ids = [
  #"subnet-09fa71506c5274edf"
]
vpc_id           = #"vpc-066122736a3c21fc2"
environment_name = #"DD Terraform"