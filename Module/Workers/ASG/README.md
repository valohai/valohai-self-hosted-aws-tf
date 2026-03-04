# ASG

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
| [aws_autoscaling_group.valohai_worker_asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_launch_template.valohai_worker_lt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_ami.valohai](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami"></a> [ami](#input\_ami) | AMI to be used for the Valohai Workers of this ASG | `string` | n/a | yes |
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | AWS profile for defining the provider | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type of Valohai workers | `string` | n/a | yes |
| <a name="input_redis_url"></a> [redis\_url](#input\_redis\_url) | Address of the redis (node) that will host the job queue and short term logs. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of subnets where Valohai workers can be placed | `list(string)` | n/a | yes |
| <a name="input_valohai_sg_workers_id"></a> [valohai\_sg\_workers\_id](#input\_valohai\_sg\_workers\_id) | AWS security group to be attached to the workers | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC Id used for the workers | `string` | n/a | yes |
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | Defines is workers should get a public IP | `bool` | `false` | no |
| <a name="input_ebs_disk_size"></a> [ebs\_disk\_size](#input\_ebs\_disk\_size) | EBS disk size for Valohai instances | `string` | `"50"` | no |
| <a name="input_env_asg_prefix"></a> [env\_asg\_prefix](#input\_env\_asg\_prefix) | Prefix for ASG names in Valohai environments | `string` | `"dev-valohai-worker-"` | no |
| <a name="input_env_queue_prefix"></a> [env\_queue\_prefix](#input\_env\_queue\_prefix) | Prefix for queue names in Valohai environments | `string` | `""` | no |
| <a name="input_instance_profile"></a> [instance\_profile](#input\_instance\_profile) | InstanceProfile to attach to Valohai Workers | `string` | `"dev-valohai-iamr-worker"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | SSH key name for worker instances | `string` | `"dev-valohai-key-workers"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
