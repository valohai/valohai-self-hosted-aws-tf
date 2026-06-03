variable "worker_account_id" {
  description = "AWS Account ID of the worker account"
  type        = string
}

variable "resource_name_prefix" {
  description = "resource_name_prefix of this (worker) deployment. Used for the worker account's master role that the policy grants AssumeRole on."
  type        = string
}

variable "control_plane_resource_name_prefix" {
  description = "resource_name_prefix used in the control plane account. The policy is attached to the control plane's master role, which uses this prefix."
  type        = string
}
