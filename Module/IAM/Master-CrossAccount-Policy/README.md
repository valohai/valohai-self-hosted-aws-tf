# Master-CrossAccount-Policy

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
| [aws_iam_role_policy.master_assume_worker_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_control_plane_resource_name_prefix"></a> [control\_plane\_resource\_name\_prefix](#input\_control\_plane\_resource\_name\_prefix) | resource\_name\_prefix used in the control plane account. The policy is attached to the control plane's master role, which uses this prefix. | `string` | n/a | yes |
| <a name="input_resource_name_prefix"></a> [resource\_name\_prefix](#input\_resource\_name\_prefix) | resource\_name\_prefix of this (worker) deployment. Used for the worker account's master role that the policy grants AssumeRole on. | `string` | n/a | yes |
| <a name="input_worker_account_id"></a> [worker\_account\_id](#input\_worker\_account\_id) | AWS Account ID of the worker account | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
