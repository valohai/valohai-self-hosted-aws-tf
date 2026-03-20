variable "vpc_id" {
  description = "VPC Id used for the workers"
  type        = string
}

variable "roi_sg_id" {
  description = "Valohai Worker security group"
  type        = string
  default     = "50"
}

variable "create_roi_ingress_rule" {
  description = "Whether to create ingress rule on ROI security group (only if workers are in same account)"
  type        = bool
  default     = false
}

variable "ec2_key" {
  description = "Location of the ssh key pub file for worker instances"
  type        = string
}
