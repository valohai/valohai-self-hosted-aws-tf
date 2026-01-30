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

variable "notebook_certificate_arn" {
  description = "Certificate ARN"
  type        = string
}

variable "valohai_roi_id" {
  description = "ID of the Valohai Roi instance"
  type        = string
}

variable "valohai_sg_roi" {
  description = "ID of the Valohai Roi instance security group"
  type        = string
}

variable "valohai_sg_workers" {
  description = "ID of the Valohai workers security group"
  type        = string
}
