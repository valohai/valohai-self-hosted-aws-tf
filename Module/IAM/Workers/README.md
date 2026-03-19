# Workers

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
| [aws_iam_instance_profile.valohai_worker_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.valohai_worker_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.valohai_worker_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ssm_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_worker_role_prefix"></a> [worker\_role\_prefix](#input\_worker\_role\_prefix) | Prefix for the worker IAM role, policy, and instance profile names | `string` | `"dev-valohai"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_worker_instance_profile_name"></a> [worker\_instance\_profile\_name](#output\_worker\_instance\_profile\_name) | n/a |
| <a name="output_worker_role"></a> [worker\_role](#output\_worker\_role) | n/a |
| <a name="output_worker_role_name"></a> [worker\_role\_name](#output\_worker\_role\_name) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
