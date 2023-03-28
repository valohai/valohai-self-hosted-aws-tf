# Valohai AWS Self Hosted Terraform

This repository contains a Terraform script to deploy a self hosted version of Valohai to AWS.

## Prerequisites

* [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
* Configure a new AWS profile with your credentials by running `aws configure --profile myname` on your workstation

## Running the Terraform template

Before starting deploying the Terraform template, you'll need to:

* Generate an SSH key that will be used as the key for the Valohai managed EC2 instances.
  * You can generate a key by running `ssh-keygen -m PEM -f valohai -C ubuntu` locally on your workstation.
* Update the `variables.tfvars` file and input your details there.
  
To deploy the resources:
* Run `terraform init` to initialize a working directory with Terraform configuration files.
* Run `terraform plan -out="valohai-init" -var-file=variables.tfvars` to create an execution plan and see what kind of changes will be applied to your AWS Project.
* Finally run `terraform apply "valohai-init"` to configure the resources needed for a Valohai Hybrid AWS Installation.

After you've created all the resources, you'll need to share the outputs with your Valohai contact (master_iam, secret_name, valohai_queue_private_ip, valohai_queue_public_ip)

## Removing Valohai resources

The Postgresql database for Valohai data has delete protection on and it won't be deleted by default.
The S3 Bucket containing all won't be deleted unless you empty it fully.

To delete the Postgresql database:
* Update the `aws_db_instance` resource properties by setting `deletion_protection` to `false` in `Module/Postgres/main.tf`
* Run `terraform plan -out="valohai-postgres-update" -var-file=variables.tfvars` && `terraform apply "valohai-postgres-update"`

To empty & delete the S3 Bucket:
* Update the `aws_s3_bucket` resource properties by setting  `force_destroy` to `true` in `Module/S3/main.tf`
* Run `terraform plan -out="valohai-s3-update" -var-file=variables.tfvars` && `terraform apply "valohai-s3-update"`

You can then delete all the resources with:
* Run `terraform destroy -var-file=variables.tfvars`

## Development

Enforce Terraform styling guides with `terraform fmt -recursive`

You can also setup `tflint` to lint for common TF issues
https://github.com/terraform-linters/tflint
And then run 
```bash
tflint --recursive
```
