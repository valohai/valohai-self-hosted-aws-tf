variable "worker_role_prefix" {
  description = "Prefix for the worker IAM role, policy, and instance profile names"
  type        = string
  default     = "dev-valohai"
}
