variable "aws_profile" {
  description = "AWS profile for defining the provider"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}
variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "s3_bucket_name" {
  description = "Unique name for the S3 bucket that's used as the default output storage for Valohai"
  type        = string
}

variable "enable_cross_account_trust" {
  description = "Enable trust relationship to allow control plane account to assume this role (set to true when creating worker account master role)"
  type        = bool
  default     = false
}

variable "control_plane_account_id" {
  description = "AWS Account ID of the control plane (only used when enable_cross_account_trust is true)"
  type        = string
  default     = ""
}

variable "worker_role_names" {
  description = "Names of the worker IAM roles (one per environment). Used to grant iam:PassRole."
  type        = list(string)
  default     = []
}
