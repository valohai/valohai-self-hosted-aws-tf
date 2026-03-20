variable "aws_profile" {
  description = "AWS profile to be used"
  type        = string
}

variable "aws_region" {
  description = "AWS region for Valohai resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS Account ID for control plane"
  type        = string
}

variable "aws_worker_account_id" {
  description = "AWS Account ID for workers (set this when deploying workers to different account)"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "ID of VPC for Roi"
  type        = string
}

variable "worker_vpc_id" {
  description = "ID of VPC for Workers"
  type        = string
}

variable "lb_subnet_ids" {
  description = "List of subnet IDs for load balancer"
  type        = list(string)
}

variable "roi_subnet_id" {
  description = "ID of subnet for Roi"
  type        = string
}

variable "db_subnet_ids" {
  description = "ID of subnet for db"
  type        = list(string)
}

variable "worker_subnet_ids" {
  description = "A list of subnets where Valohai workers can be placed"
  type        = list(string)
}

variable "ec2_key" {
  description = "Location of the ssh key pub file that can be used for Valohai managed instances"
  type        = string
  default     = ".valohai.pub"
}

variable "s3_bucket_name" {
  description = "Unique name for the S3 bucket that's used as the default output storage for Valohai"
  type        = string
}

variable "s3_logs_name" {
  description = "Unique name for the S3 bucket that's used as the default log storage"
  type        = string
}

variable "environment_name" {
  description = "Name of the environment / organization (e.g. MyOrg)"
  type        = string
  default     = "My Valohai Org"
}

variable "domain" {
  description = "Address that will be used to access the service"
  type        = string
  default     = "" #"http://valohai.myorg.com"
}

variable "organization" {
  description = "Name of organization in Valohai (e.g. MyOrg)"
  type        = string
  default     = "MyOrg"
}

variable "environments" {
  description = "Map of Valohai environments to create. Each key is a stable identifier (changing the key destroys and recreates ASGs). Each environment can target different organizations, queues, and instance types."
  type = map(object({
    env_owner_id            = string
    env_name_prefix         = string
    env_asg_prefix          = string
    env_queue_prefix        = string
    worker_role_prefix      = string
    redis_url               = string
    aws_instance_types      = list(string)
    add_spot_instances      = bool
    aws_spot_instance_types = list(string)
  }))
}

variable "certificate_arn" {
  description = "Certificate ARN"
  type        = string
  default     = "" # "arn:aws:acm:REGION:ACCOUNT:certificate/ID"
}

variable "ami_id" {
  description = "AMI id from your Valohai contact"
  type        = string
  default     = ""
}

variable "install_control_plane" {
  description = "Install control plane resources (ROI, database, Redis, LB). Set to true for control plane deployment, false for worker-only deployment."
  type        = bool
  default     = true
}

variable "install_workers" {
  description = "Define if should install the module Workers, false for app installation"
  type        = bool
  default     = false
}

variable "redis_url" {
  description = "Connection string for the Redis queue, e.g. ':<password>@<URL>'"
  type        = string

}


variable "workers_in_control_plane" {
  description = "Set to true when workers are in the same AWS account as control plane. Enables direct security group rule between workers and ROI. Set to false for cross-account deployments."
  type        = bool
  default     = false
}
