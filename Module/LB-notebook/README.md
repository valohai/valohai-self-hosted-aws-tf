# LB-notebook

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
| [aws_lb.valohai_nb_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.https_notebook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.valohai_notebook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.valohai_roi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_security_group.valohai_sg_nb_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.allow_nb_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_nb_lb_on_roi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_nb_workers_on_roi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | AWS Account ID | `string` | n/a | yes |
| <a name="input_lb_subnet_ids"></a> [lb\_subnet\_ids](#input\_lb\_subnet\_ids) | Subnet used for core Valohai web app and scaling services (Roi) | `list(string)` | n/a | yes |
| <a name="input_notebook_certificate_arn"></a> [notebook\_certificate\_arn](#input\_notebook\_certificate\_arn) | Certificate ARN | `string` | n/a | yes |
| <a name="input_valohai_roi_id"></a> [valohai\_roi\_id](#input\_valohai\_roi\_id) | ID of the Valohai Roi instance | `string` | n/a | yes |
| <a name="input_valohai_sg_roi"></a> [valohai\_sg\_roi](#input\_valohai\_sg\_roi) | ID of the Valohai Roi instance security group | `string` | n/a | yes |
| <a name="input_valohai_sg_workers"></a> [valohai\_sg\_workers](#input\_valohai\_sg\_workers) | ID of the Valohai workers security group | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC Id used for ELB | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | n/a |
| <a name="output_target_group_id"></a> [target\_group\_id](#output\_target\_group\_id) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
