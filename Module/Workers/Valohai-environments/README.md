# Valohai-environments

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_instance.valohai_environments_setup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_add_spot_instances"></a> [add\_spot\_instances](#input\_add\_spot\_instances) | Set to true when adding spot instances. | `bool` | n/a | yes |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | AMI id from your Valohai contact | `string` | n/a | yes |
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | AWS Account ID | `string` | n/a | yes |
| <a name="input_aws_instance_types"></a> [aws\_instance\_types](#input\_aws\_instance\_types) | A list of AWS instance types that should be created | `list(string)` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_aws_spot_instance_types"></a> [aws\_spot\_instance\_types](#input\_aws\_spot\_instance\_types) | A list of AWS spot instance types that should be created | `list(string)` | n/a | yes |
| <a name="input_domain"></a> [domain](#input\_domain) | Address that will be used to access the service | `string` | n/a | yes |
| <a name="input_env_setup_sg_id"></a> [env\_setup\_sg\_id](#input\_env\_setup\_sg\_id) | Security group ID for the environment setup machine | `string` | n/a | yes |
| <a name="input_redis_url"></a> [redis\_url](#input\_redis\_url) | Address of the redis (node) that will host the job queue and short term logs. | `string` | n/a | yes |
| <a name="input_roi_subnet_id"></a> [roi\_subnet\_id](#input\_roi\_subnet\_id) | Subnet used for the temporary setup machine under the control plane account | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC Id used for the workers | `string` | n/a | yes |
| <a name="input_aws_worker_account_id"></a> [aws\_worker\_account\_id](#input\_aws\_worker\_account\_id) | AWS Account ID for workers | `string` | `""` | no |
| <a name="input_env_asg_prefix"></a> [env\_asg\_prefix](#input\_env\_asg\_prefix) | Prefix for ASG names in Valohai environments | `string` | `"dev-valohai-worker-"` | no |
| <a name="input_env_name_prefix"></a> [env\_name\_prefix](#input\_env\_name\_prefix) | Prefix for Valohai environment names | `string` | `""` | no |
| <a name="input_env_owner_id"></a> [env\_owner\_id](#input\_env\_owner\_id) | Environment owner ID in Valohai | `string` | `"1"` | no |
| <a name="input_env_queue_prefix"></a> [env\_queue\_prefix](#input\_env\_queue\_prefix) | Prefix for queue names in Valohai environments | `string` | `""` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
