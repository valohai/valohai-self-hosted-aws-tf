terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "valohai-self-hosted-tf-state"
    dynamodb_table = "terraform-state-lock-dynamo"
    key            = "terraform.tfstate"
    region         = "us-east-1"
  }
}
