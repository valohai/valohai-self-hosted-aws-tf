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
  description = "AWS Account ID"
  type        = string
}

variable "vpc_id" {
  description = "ID of VPC for Roi"
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

variable "certificate_arn" {
  description = "Certificate ARN"
  type        = string
  default     = "" # "arn:aws:acm:REGION:ACCOUNT:certificate/ID"
}

variable "aws_instance_types" {
  description = "List of AWS instance types that should be created"
  type        = list(string)
  default = [
    "t3.small",
    "c5.xlarge",
    "p3.2xlarge"
  ]
}