aws_profile      =  # your AWS profile (under ~/.aws/credentials) 
region           = # e.g. eu-central-1
ec2_key          = # path to your .pub key
public_subnet_id = # subnet ID for Valohai web app and scaling services (roi)
db_subnet_ids = [ # (Private) subnet IDs for Postgres, Redis, and workers

]
vpc_id           = # VPC ID
environment_name = # Your organization name