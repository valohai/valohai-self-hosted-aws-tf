# EC2

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_instance.valohai_roi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_key_pair.valohai_roi_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_kms_alias.valohai_kms_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.valohai_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_lb_target_group_attachment.valohai_roi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_security_group.valohai_sg_roi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.valohai_sg_workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ssm_parameter.jwt_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.repo_private_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.secret_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [random_password.jwt_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.repo_private_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.secret_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_ami.valohai](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_add_spot_instances"></a> [add_spot_instances](#input\_add\_spot\_instances) | Set to true when adding spot instances | `bool` | `false` | yes |
| <a name="input_ami_id"></a> [ami_id](#input\_ami\_id) | AMI id from your Valohai contact | `string` | `""` | yes |
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | AWS Account ID | `string` | n/a | yes |
| <a name="input_aws_instance_types"></a> [aws\_instance\_types](#input\_aws\_instance\_types) | List of AWS instance types that should be created | `list(string)` | <pre>[<br>  "t3.small",<br>  "c5.2xlarge", <br>  "p3.2xlarge"<br>]</pre> | no |
| <a name="input_aws_spot_instance_types"></a> [aws\_spot\_instance\_types](#input\_aws\_spot\_instance\_types) | List of AWS spot instance types that should be created | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | Password for the Postgresql database | `string` | n/a | yes |
| <a name="input_db_url"></a> [db\_url](#input\_db\_url) | Address of the Postgresql database used for Valohai | `string` | n/a | yes |
| <a name="input_domain"></a> [domain](#input\_domain) | Address that will be used to access the service | `string` | n/a | yes |
| <a name="input_ec2_key"></a> [ec2\_key](#input\_ec2\_key) | Local location of the public key that should be attached to the Valohai owned EC2 instances | `string` | n/a | yes |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | Name of the environment / organization (e.g. MyOrg) | `string` | n/a | yes |
| <a name="input_lb_sg"></a> [lb\_sg](#input\_lb\_sg) | Security Group for load balancer | `string` | n/a | yes |
| <a name="input_lb_target_group_id"></a> [lb\_target\_group\_id](#input\_lb\_target\_group\_id) | ARN of the load balancer | `string` | n/a | yes |
| <a name="input_organization"></a> [organization](#input\_organization) | Name of the organization in Valohai (e.g. MyOrg) | `string` | `"MyOrg"` | no |
| <a name="input_redis_url"></a> [redis\_url](#input\_redis\_url) | Address of the redis (node) that will host the job queue and short term logs. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region | `string` | n/a | yes |
| <a name="input_roi_subnet_id"></a> [roi\_subnet\_id](#input\_roi\_subnet\_id) | Subnet used for core Valohai web app and scaling services (Roi) | `string` | n/a | yes |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | Unique name for the S3 bucket that's used as the default output storage for Valohai | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC Id used for ELB | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | n/a |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | n/a |
| <a name="output_worker_security_group_id"></a> [worker\_security\_group\_id](#output\_worker\_security\_group\_id) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
