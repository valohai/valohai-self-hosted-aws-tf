variable "vpc_id" {
  description = "VPC Id used for ELB"
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnets where Valohai workers can be placed"
  type        = list(string)
}

variable "ami" {
  description = "AMI to be used for the Valohai Workers of this ASG"
  type        = string
}

variable "redis_url" {
  description = "Address of the redis (node) that will host the job queue and short term logs."
  type        = string
}

variable "instance_type" {
  description = "Instance type of Valohai workers"
  type        = string
}

variable "region" {
  description = "Region"
  type        = string
}

variable "assign_public_ip" {
  description = "Defines is workers should get a public IP"
  type        = bool
  default     = false
}

variable "instance_profile" {
  description = "InstanceProfile to attach to Valohai Workers"
  type        = string
  default     = "ValohaiWorkerProfile"
}

variable "ebs_disk_size" {
  description = "EBS disk size for Valohai instances"
  type        = string
  default     = "50"
}
