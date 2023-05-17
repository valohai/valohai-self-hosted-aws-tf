variable "region" {
  description = "Region"
  type        = string
}

variable "vpc_id" {
  description = "VPC Id used for ELB"
  type        = string
}

variable "bastion_subnet_id" {
  description = "Subnet used for bastion"
  type        = string
}

variable "ec2_key" {
  description = "Local location of the public key that should be attached to the Valohai owned EC2 instances"
  type        = string
}