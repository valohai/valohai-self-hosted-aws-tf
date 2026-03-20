# Security-groups

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
| [aws_key_pair.valohai_worker_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_security_group.valohai_sg_workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.allow_workers_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ec2_key"></a> [ec2\_key](#input\_ec2\_key) | Location of the ssh key pub file for worker instances | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC Id used for the workers | `string` | n/a | yes |
| <a name="input_create_roi_ingress_rule"></a> [create\_roi\_ingress\_rule](#input\_create\_roi\_ingress\_rule) | Whether to create ingress rule on ROI security group (only if workers are in same account) | `bool` | `false` | no |
| <a name="input_roi_sg_id"></a> [roi\_sg\_id](#input\_roi\_sg\_id) | Valohai Worker security group | `string` | `"50"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_worker_key_name"></a> [worker\_key\_name](#output\_worker\_key\_name) | Key pair name for worker instances |
| <a name="output_worker_security_group_id"></a> [worker\_security\_group\_id](#output\_worker\_security\_group\_id) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
