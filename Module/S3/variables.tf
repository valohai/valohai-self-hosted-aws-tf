variable "domain" {
  description = "Address that will be used to access the service"
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

variable "s3_logs_name" {
  description = "Unique name for the S3 bucket that's used as the default log storage"
  type        = string
}
