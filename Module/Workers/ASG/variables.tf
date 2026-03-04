variable "aws_profile" {
  description = "AWS profile for defining the provider"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "vpc_id" {
  description = "VPC Id used for the workers"
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

variable "env_asg_prefix" {
  description = "Prefix for ASG names in Valohai environments"
  type        = string
  default     = "dev-valohai-worker-"
}

variable "env_queue_prefix" {
  description = "Prefix for queue names in Valohai environments"
  type        = string
  default     = ""
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
  default     = "dev-valohai-iamr-worker"
}

variable "ebs_disk_size" {
  description = "EBS disk size for Valohai instances"
  type        = string
  default     = "50"
}

variable "valohai_sg_workers_id" {
  description = "AWS security group to be attached to the workers"
  type        = string
}

variable "key_name" {
  description = "SSH key name for worker instances"
  type        = string
  default     = "dev-valohai-key-workers"
}
