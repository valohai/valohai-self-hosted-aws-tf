variable "aws_profile" {
  description = "AWS Profile name (~/.aws/credentials)"
  type        = string
}

variable "region" {
  description = "AWS region for Valohai resources"
  type        = string
}

variable "vpc_id" {
  description = "ID of VPC for Roi"
  type        = string
}

variable "public_subnet_id" {
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
}

variable "environment_name" {
  description = "Name of the environment / organization (e.g. MyOrg)"
  type        = string
}

variable "aws_instances_types" {
  description = "List of AWS instance types that should be created"
  type        = list(string)
  default = [
    "t3.small",
    "t3.medium",
    "c5.xlarge",
    "c5.2xlarge",
    "c5.4xlarge",
    "r4.xlarge",
    "p2.xlarge",
    "p3.2xlarge"
  ]
}