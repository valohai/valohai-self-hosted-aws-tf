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


variable "ec2_key" {
  description = "Location of the ssh key pub file that can be used for Valohai managed instances"
  type        = string
}

variable "environment_name" {
  description = "Name of the environment / organization (e.g. MyOrg)"
  type        = string
}
