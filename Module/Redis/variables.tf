variable "vpc_id" {
  description = "VPC Id used for ELB"
  type        = string
}

variable "cache_subnet_ids" {
  description = "A list of (private) subnets for the Redis Elasticache used to store short-term logs and the job queue."
  type        = list(string)
}

variable "resource_name_prefix" {
  description = "Prefix for all named AWS resources"
  type        = string
}
