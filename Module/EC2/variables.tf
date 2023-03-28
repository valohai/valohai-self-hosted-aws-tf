variable "region" {
  description = "Region"
  type        = string
}

variable "subnet_id" {
  description = "(Public) subnet used for core Valohai web app and scaling services (Roi)"
  type        = string
}

variable "security_group_id" {
  description = "Security Group for the web app and scaling services (Roi) instance"
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
