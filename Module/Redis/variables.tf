
variable "cache_subnet_ids" {
  description = "A list of (private) subnets for the Redis Elasticache used to store short-term logs and the job queue."
  type        = list(string)
}

variable "security_group_ids" {
  description = "ID of the generated security group for Redis"
  type        = list(string)
}