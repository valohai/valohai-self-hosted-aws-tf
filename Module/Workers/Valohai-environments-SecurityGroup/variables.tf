variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "resource_name_prefix" {
  description = "Prefix for all named AWS resources"
  type        = string
}
