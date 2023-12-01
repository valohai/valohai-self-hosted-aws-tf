# Valohai AWS Self Hosted Terraform

This repository contains a Terraform script to deploy a self hosted version of Valohai to AWS.

## Prerequisites

* [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
* Configure a new AWS profile with your credentials by running `aws configure --profile myname` on your workstation

## Running the Terraform template

Before starting deploying the Terraform template, you'll need to:

* Generate an SSH key that will be used as the key for the Valohai managed EC2 instances.
  * You can generate a key by running `ssh-keygen -m PEM -f .valohai-key -C ubuntu` locally on your workstation.
* Update the `variables.tfvars` file and input your details there.

To deploy the resources:
* Run `terraform init` to initialize a working directory with Terraform configuration files.
* Run `terraform plan -out="valohai-init" -var-file=variables.tfvars` to create an execution plan and see what kind of changes will be applied to your AWS Project.
* Finally run `terraform apply "valohai-init"` to configure the resources needed for a Valohai Hybrid AWS Installation.

### Important
This example template will create an EC2 instance with port 80 open to the world. Users can then access the Valohai environment directly through their browser. It's a best practice to use HTTPS and forward all of your HTTP requets to HTTPS.

To enable HTTPS with your custom certificate you'll need to apply the following changes:

First, create SSL the certificate in your AWS Console. Once you have a certificate, place it's ARN to the `variables.tfvars` file.

Edit `Module/LB/main.tf` and update the http listener to redirect instead of forwarding the request to the instance.
```
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.valohai_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
```
> Then add the required resources to enable HTTPS.
```
resource "aws_lb_listener" "https" {
  #checkov:skip=CKV_AWS_103:Checkov false positive, policy supports TLS 1.2
  load_balancer_arn = aws_lb.valohai_lb.id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    target_group_arn = aws_lb_target_group.valohai_roi.arn
    type             = "forward"
  }
}

resource "aws_lb_listener_certificate" "valohai_cert" {
  listener_arn    = aws_lb_listener.https.arn
  certificate_arn = var.certificate_arn
}
```
Finally update the security group of the load balancer to only allow access on port 443 instead of 80.
```
resource "aws_security_group" "valohai_sg_lb" {
  name        = "dev-valohai-sg-alb"
  description = "for Valohai ELB"

  vpc_id = var.vpc_id

  ingress {
    description = "for ELB"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "valohai_sg_lb",
  }
}
```

## Removing Valohai resources

The Postgresql database for Valohai data and the load balancer have delete protection on and they won't be deleted by default.
The S3 Bucket containing all won't be deleted unless you empty it fully.

To delete the Postgresql database:
* Update the `aws_db_instance` resource properties by setting `deletion_protection` to `false` in `Module/Postgres/main.tf`
* Run `terraform plan -out="valohai-postgres-update" -var-file=variables.tfvars` && `terraform apply "valohai-postgres-update"`

To delete the load balancer:
* Update the `aws_lb` resource properties by setting `enable_deletion_protection` to `false` in `Module/LB/main.tf`
* Run `terraform plan -out="valohai-lb-update" -var-file=variables.tfvars` && `terraform apply "valohai-lb-update"`

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

There are a series of pre-commit hooks implemented for testing, TFdocs, and styling. You can manually trigger them with `pre-commit run --all-files`

Update TF Docs with
```
terraform-docs markdown table --output-file README.md --output-mode inject .
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.6.3 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ASG"></a> [ASG](#module\_ASG) | ./Module/ASG | n/a |
| <a name="module_ASG-spots"></a> [ASG-spots](#module\_ASG-spots) | ./Module/ASG-spots | n/a |
| <a name="module_Database"></a> [Database](#module\_Database) | ./Module/Postgres | n/a |
| <a name="module_EC2"></a> [EC2](#module\_EC2) | ./Module/EC2 | n/a |
| <a name="module_IAM_Master"></a> [IAM\_Master](#module\_IAM\_Master) | ./Module/IAM/Master | n/a |
| <a name="module_IAM_S3"></a> [IAM\_S3](#module\_IAM\_S3) | ./Module/IAM/S3 | n/a |
| <a name="module_IAM_Workers"></a> [IAM\_Workers](#module\_IAM\_Workers) | ./Module/IAM/Workers | n/a |
| <a name="module_LB"></a> [LB](#module\_LB) | ./Module/LB | n/a |
| <a name="module_Redis"></a> [Redis](#module\_Redis) | ./Module/Redis | n/a |
| <a name="module_S3"></a> [S3](#module\_S3) | ./Module/S3 | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_add_spot_instances"></a> [add\_spot\_instances](#input\_add\_spot\_instances) | Set to true when adding spot instances. | `bool` | `false` | no |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | AMI id from your Valohai contact | `string` | `""` | no |
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | AWS Account ID | `string` | n/a | yes |
| <a name="input_aws_instance_types"></a> [aws\_instance\_types](#input\_aws\_instance\_types) | List of AWS instance types that should be created | `list(string)` | <pre>[<br>  "t3.small",<br>  "c5.xlarge",<br>  "p3.2xlarge"<br>]</pre> | no |
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | AWS profile to be used | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region for Valohai resources | `string` | `"us-east-1"` | no |
| <a name="input_aws_spot_instance_types"></a> [aws\_spot\_instance\_types](#input\_aws\_spot\_instance\_types) | List of AWS spot instance types that should be created | `list(string)` | `[]` | no |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | Certificate ARN | `string` | `""` | no |
| <a name="input_db_subnet_ids"></a> [db\_subnet\_ids](#input\_db\_subnet\_ids) | ID of subnet for db | `list(string)` | n/a | yes |
| <a name="input_domain"></a> [domain](#input\_domain) | Address that will be used to access the service | `string` | `""` | no |
| <a name="input_ec2_key"></a> [ec2\_key](#input\_ec2\_key) | Location of the ssh key pub file that can be used for Valohai managed instances | `string` | `".valohai.pub"` | no |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | Name of the environment / organization (e.g. MyOrg) | `string` | `"My Valohai Org"` | no |
| <a name="input_lb_subnet_ids"></a> [lb\_subnet\_ids](#input\_lb\_subnet\_ids) | List of subnet IDs for load balancer | `list(string)` | n/a | yes |
| <a name="input_organization"></a> [organization](#input\_organization) | Name of organization in Valohai (e.g. MyOrg) | `string` | `"MyOrg"` | no |
| <a name="input_roi_subnet_id"></a> [roi\_subnet\_id](#input\_roi\_subnet\_id) | ID of subnet for Roi | `string` | n/a | yes |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | Unique name for the S3 bucket that's used as the default output storage for Valohai | `string` | n/a | yes |
| <a name="input_s3_logs_name"></a> [s3\_logs\_name](#input\_s3\_logs\_name) | Unique name for the S3 bucket that's used as the default log storage | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of VPC for Roi | `string` | n/a | yes |
| <a name="input_worker_subnet_ids"></a> [worker\_subnet\_ids](#input\_worker\_subnet\_ids) | A list of subnets where Valohai workers can be placed | `list(string)` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
