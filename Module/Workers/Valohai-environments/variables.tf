variable "aws_profile" {
  description = "AWS profile for defining the provider"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "aws_worker_account_id" {
  description = "AWS Account ID for workers"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "VPC Id used for the workers"
  type        = string
}

variable "env_setup_sg_id" {
  description = "Security group ID for the environment setup machine"
  type        = string
}

variable "roi_subnet_id" {
  description = "Subnet used for the temporary setup machine under the control plane account"
  type        = string
}


variable "ec2_key" {
  description = "Local location of the public key that should be attached to the Valohai owned EC2 instances"
  type        = string
}

variable "redis_url" {
  description = "Address of the redis (node) that will host the job queue and short term logs."
  type        = string
}

variable "domain" {
  description = "Address that will be used to access the service"
  type        = string
}

variable "organization" {
  description = "Name of the organization in Valohai (e.g. MyOrg)"
  type        = string
}

variable "ami_id" {
  description = "AMI id from your Valohai contact"
  type        = string
}

variable "env_owner_id" {
  description = "Environment owner ID in Valohai"
  type        = string
  default     = "1"
}

variable "env_name_prefix" {
  description = "Prefix for Valohai environment names"
  type        = string
  default     = ""
}

variable "env_asg_prefix" {
  description = "Prefix for ASG names in Valohai environments"
  type        = string
  default     = "dev-valohai-worker-"
}

variable "env_queue_prefix" {
  description = "Prefix for queue names in Valohai environments"
  type        = string
  default     = ""
}

variable "aws_instance_types" {
  description = "A list of AWS instance types that should be created"
  type        = list(string)
}

variable "add_spot_instances" {
  description = "Set to true when adding spot instances."
  type        = bool
}

variable "aws_spot_instance_types" {
  description = "A list of AWS spot instance types that should be created"
  type        = list(string)
}
