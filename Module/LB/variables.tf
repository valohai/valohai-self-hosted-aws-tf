variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "vpc_id" {
  description = "VPC Id used for ELB"
  type        = string
}

variable "lb_subnet_ids" {
  description = "Subnet used for core Valohai web app and scaling services (Roi)"
  type        = list(string)
}

variable "certificate_arn" {
  description = "Certificate ARN"
  type        = string
}

variable "s3_logs_name" {
  description = "Unique name for the S3 bucket that's used as the default log storage"
  type        = string
}
