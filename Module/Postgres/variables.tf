variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "vpc_id" {
  description = "VPC Id where the Valohai Postgresql database will be placed in."
  type        = string
}

variable "db_subnet_ids" {
  description = "A list of (private) subnets for the Postgresql database. Minimum two subnets."
  type        = list(string)
}
