variable "region" {
  description = "Region"
  type        = string
}

variable "vpc_id" {
  description = "VPC Id used for ELB"
  type        = string
}

variable "roi_subnet_id" {
  description = "Subnet used for core Valohai web app and scaling services (Roi)"
  type        = string
}

variable "elb_subnet_ids" {
  description = "Public subnets used for the ELB"
  type        = list(string)
}

variable "roi_security_group_ids" {
  description = "List of Security Group IDs for the web app and scaling services (Roi) instance"
  type        = list(string)
}

variable "elb_security_group_ids" {
  description = "List of Security Group IDs for ELB"
  type        = list(string)
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
