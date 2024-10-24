variable "region" {
  description = "Region"
  type        = string
}

variable "vpc_id" {
  description = "VPC Id used for ELB"
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "roi_subnet_id" {
  description = "Subnet used for core Valohai web app and scaling services (Roi)"
  type        = string
}

variable "lb_target_group_id" {
  description = "ARN of the load balancer"
  type        = string
}

variable "lb_sg" {
  description = "Security Group for load balancer"
  type        = string
}

variable "s3_bucket_name" {
  description = "Unique name for the S3 bucket that's used as the default output storage for Valohai"
  type        = string
}

variable "s3_kms_key" {
  description = "ARN of the created S3 bucket"
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

variable "db_url" {
  description = "Address of the Postgresql database used for Valohai"
  type        = string
}

variable "db_password" {
  description = "Password for the Postgresql database"
  type        = string
  sensitive   = true
}

variable "environment_name" {
  description = "Name of the environment / organization (e.g. MyOrg)"
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