variable "vpc_id" {
  description = "VPC Id where the Valohai Postgresql database will be placed in."
  type        = string
}

variable "db_subnet_ids" {
  description = "A list of (private) subnets for the Postgresql database. Minimum two subnets."
  type        = list(string)
}

variable "security_group_ids" {
  description = "ID of the generated security group for Postgresql"
  type        = list(string)
}