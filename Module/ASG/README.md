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
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type of Valohai workers | `string` | n/a | yes |
| <a name="input_redis_url"></a> [redis\_url](#input\_redis\_url) | Address of the redis (node) that will host the job queue and short term logs. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of subnets where Valohai workers can be placed | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC Id used for ELB | `string` | n/a | yes |
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | Defines is workers should get a public IP | `bool` | `false` | no |
| <a name="input_ebs_disk_size"></a> [ebs\_disk\_size](#input\_ebs\_disk\_size) | EBS disk size for Valohai instances | `string` | `"50"` | no |
| <a name="input_instance_profile"></a> [instance\_profile](#input\_instance\_profile) | InstanceProfile to attach to Valohai Workers | `string` | `"dev-valohai-iamr-worker"` | no |
| <a name="input_worker_sg_id"></a> [worker\_sg\_id](#input\_worker\_sg\_id) | Valohai Worker security group | `string` | `"50"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
