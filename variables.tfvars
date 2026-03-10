aws_profile           = ""
aws_region            = ""
aws_account_id        = "" # Control plane account ID
aws_worker_account_id = "" # Worker account ID
ec2_key               = "" # path to your .pub key
lb_subnet_ids = [          # Subnets for the ELB

]
roi_subnet_id = "" # Subnet for the control plane
db_subnet_ids = [

]
worker_subnet_ids = [ # Subnets for the workers

]
vpc_id           = "" # VPC id for the control plane
worker_vpc_id    = "" # VPC id for workers
environment_name = "Valohai"
s3_bucket_name   = ""
s3_logs_name     = ""
domain           = ""
certificate_arn  = ""
organization     = ""
ami_id           = "" # AMI id from your Valohai contact

# Define what will be installed
install_control_plane    = true                                                         # True for single account installations, false for cross-account worker installation
install_workers          = false                                                        # false for initial app installation
workers_in_control_plane = true                                                         # Set to true if workers are in the same AWS account as ROI
redis_url                = "dev-valohai-elc-queue.vpzxtx.0001.use1.cache.amazonaws.com" # Global fallback Redis URL from the control plane deployment

# Worker setup
environments = {
  "dev" = {
    env_owner_id            = ""
    env_name_prefix         = ""
    env_asg_prefix          = "dev-valohai-worker-test-"
    env_queue_prefix        = ""
    redis_url               = "" # Overrides global redis_url if set; leave empty to use the global value
    aws_instance_types      = ["t3.small"]
    add_spot_instances      = false
    aws_spot_instance_types = ["t3.medium"]
  }
}
