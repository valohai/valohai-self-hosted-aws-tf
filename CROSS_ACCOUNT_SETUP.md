# Cross-Account Deployment Guide

This guide explains how to deploy Valohai across two AWS accounts using Terraform.

## Architecture

- **Control Plane Account**: Hosts the Valohai ROI application, database, Redis, load balancer, and environment setup machine
- **Worker Account**: Hosts the worker ASGs that process Valohai jobs

## Deployment Steps

### Important: Separate Configuration Files

**You need different `variables.tfvars` files for each deployment.** Create two separate files:
- `variables-control-plane.tfvars` - For control plane deployment
- `variables-worker.tfvars` - For worker deployment in different account

**Key differences between the files:**

| Variable | Control Plane | Worker Account |
|----------|---------------|----------------|
| `aws_profile` | Control plane AWS profile | Worker account AWS profile |
| `aws_worker_account_id` | Same as `aws_account_id` | Different worker account ID |
| `worker_vpc_id` | Same as `vpc_id` | Worker account VPC ID |
| `worker_subnet_ids` | Control plane subnets | Worker account subnets |
| `install_control_plane` | `true` | `false` |
| `install_workers` | `false` or `true` | `true` |
| `workers_in_control_plane` | `true` (if installing workers) | `false` |
| `redis_url` | `""` (empty) | Redis URL for workers in the worker account |

### Step 1: Deploy Control Plane

**Configuration:**
```hcl
# variables.tfvars
aws_profile = "your-control-plane-profile"  # Your control plane AWS profile
aws_account_id = "123456789012"  # Your control plane account ID
aws_worker_account_id = "987654321098"  # Your worker account ID
install_control_plane = true
install_workers = false
workers_in_control_plane = false
```

**What gets created:**
- `dev-valohai-iamr-master` role in control plane account (for ROI instance)
- Valohai ROI EC2 instance
- PostgreSQL database
- Redis cache
- S3 buckets
- Load balancer
- IAM S3 policies

**Deploy:**
```bash
# Initialize with control plane backend configuration
terraform init \
  -backend-config="key=control-plane/terraform.tfstate" \
  -backend-config="profile=<STATE_BUCKET_PROFILE>" \
  -reconfigure

terraform plan -var-file=variables-control-plane.tfvars
terraform apply -var-file=variables-control-plane.tfvars
```

### Step 2: Deploy Workers in Different Account

**Configuration:**
```hcl
# variables.tfvars
aws_profile = "your-worker-profile"  # Your worker account AWS profile
aws_account_id = "123456789012"  # Your control plane account ID (same as Step 1)
aws_worker_account_id = "987654321098"  # Your worker account ID
install_control_plane = false
install_workers = true
workers_in_control_plane = false  # Workers in different account
redis_url = "redis://your-redis-endpoint:6379"  # Redis URL from Step 1
```

**What gets created:**
- `dev-valohai-iamr-master` role in worker account (with trust relationship to control plane)
- Worker ASGs (on-demand and spot)
- Worker security groups
- Worker SSH key (`dev-valohai-key-workers`)
- Environment setup security group in control plane
- Environment setup EC2 instance in control plane
- **Cross-account policy** added to control plane's `dev-valohai-iamr-master` role

**Deploy:**
```bash
# Initialize with worker account backend configuration
terraform init \
  -backend-config="key=worker-account/terraform.tfstate" \
  -backend-config="profile=<STATE_BUCKET_PROFILE>" \
  -reconfigure

terraform plan -var-file=variables-worker.tfvars
terraform apply -var-file=variables-worker.tfvars
```

## How Cross-Account Access Works

### 1. Worker Account Master Role
The `dev-valohai-iamr-master` role in the worker account has:

**Trust Relationship:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::<CONTROL_PLANE_ACCOUNT_ID>:role/dev-valohai-iamr-master"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

This allows:
- EC2 instances in the worker account to use this role
- The control plane's master role to assume this role for cross-account access

### 2. Control Plane Master Role
The `dev-valohai-iamr-master` role in the control plane account has an additional policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowAssumeWorkerAccountMasterRole",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "arn:aws:iam::<WORKER_ACCOUNT_ID>:role/dev-valohai-iamr-master"
    }
  ]
}
```

### 3. Using Cross-Account Access

From the setup instance in the control plane account:

```bash
# Assume the worker account role
aws sts assume-role \
  --role-arn "arn:aws:iam::<WORKER_ACCOUNT_ID>:role/dev-valohai-iamr-master" \
  --role-session-name "valohai-setup"

# Or use AWS CLI profiles
aws configure set role_arn arn:aws:iam::<WORKER_ACCOUNT_ID>:role/dev-valohai-iamr-master --profile worker-account
aws configure set source_profile default --profile worker-account

# Access worker account resources
aws ec2 describe-vpcs --profile worker-account --region <YOUR_REGION>
```

## Modules Involved

### IAM/Master
- Creates the `dev-valohai-iamr-master` role
- Conditionally adds cross-account trust when `enable_cross_account_trust = true`
- Used in both control plane and worker account deployments
- Account ID used depends on deployment type:
  - Control plane deployment: uses `aws_account_id`
  - Worker deployment: uses `aws_worker_account_id`

### IAM/Master-CrossAccount-Policy
- Adds AssumeRole permission to control plane's master role
- Only created during worker deployment when `install_workers = true` and `workers_in_control_plane = false`
- Uses `control-plane-account` provider to update control plane resources

### Workers/Valohai-environments-SecurityGroup
- Creates security group for the environment setup machine
- Only created when `install_control_plane = true`
- Always created in the control plane VPC
- Allows outbound traffic for the setup machine

### Workers/Valohai-environments
- Creates temporary EC2 instance for setting up Valohai environments
- Only created when `install_workers = true`
- Runs in control plane account but configures worker resources
- Uses cross-account IAM role assumption to access worker account

### Workers/Security-groups
- Creates worker security groups and SSH keys
- Only created when `install_workers = true`
- Conditionally creates ingress rule to ROI when `workers_in_control_plane = true`

### Workers/ASG and Workers/ASG-spots
- Creates Auto Scaling Groups for on-demand and spot instances
- Only created when `install_workers = true`
- Uses `for_each` to create multiple ASGs based on instance types

## Variables

| Variable | Description | Control Plane | Worker Deployment |
|----------|-------------|---------------|-------------------|
| `aws_profile` | AWS CLI profile to use | Control plane profile | Worker account profile |
| `aws_account_id` | Control plane account ID | Your control plane ID | Your control plane ID |
| `aws_worker_account_id` | Worker account ID | Your worker ID | Your worker ID |
| `install_control_plane` | Install control plane resources | `true` | `false` |
| `install_workers` | Install worker resources | `false` | `true` |
| `workers_in_control_plane` | Workers in same account as control plane | `false` | `false` |
| `redis_url` | Redis URL from control plane | Empty (created locally) | URL from Step 1 |

## State Management

When deploying to different AWS accounts, you need to manage separate Terraform state files. This is done using backend configuration overrides.

### Backend Configuration

Before running `terraform plan` or `terraform apply`, you must initialize Terraform with the appropriate backend configuration:

**For Control Plane Deployment:**
```bash
terraform init \
  -backend-config="key=control-plane/terraform.tfstate" \
  -backend-config="profile=<STATE_BUCKET_PROFILE>" \
  -reconfigure
```

**For Worker Account Deployment:**
```bash
terraform init \
  -backend-config="key=worker-account/terraform.tfstate" \
  -backend-config="profile=<STATE_BUCKET_PROFILE>" \
  -reconfigure
```

### Configuration Parameters

- **`key`**: Path to the state file in the S3 bucket
  - Use different paths for different accounts (e.g., `control-plane/terraform.tfstate`, `worker-account/terraform.tfstate`)
  - This ensures each deployment has its own state file

- **`profile`**: AWS profile for the account where the S3 state bucket is located
  - This should point to the account hosting your Terraform state bucket
  - Typically the control plane account or a dedicated management account

- **`-reconfigure`**: Forces Terraform to reconfigure the backend
  - Required when switching between different backend configurations
  - Ensures Terraform uses the correct state file for the current deployment

### Example Workflow

```bash
# Step 1: Deploy control plane
terraform init \
  -backend-config="key=control-plane/terraform.tfstate" \
  -backend-config="profile=<STATE_BUCKET_PROFILE>" \
  -reconfigure

terraform plan -var-file=variables-control-plane.tfvars
terraform apply -var-file=variables-control-plane.tfvars

# Step 2: Deploy workers (using separate worker tfvars file)
terraform init \
  -backend-config="key=worker-account/terraform.tfstate" \
  -backend-config="profile=<STATE_BUCKET_PROFILE>" \
  -reconfigure

terraform plan -var-file=variables-worker.tfvars
terraform apply -var-file=variables-worker.tfvars
```

### Important Notes

- Always run `terraform init` with the correct backend configuration before deploying
- The state files are kept separate to prevent conflicts between deployments
- Both state files should be accessible from the profile specified in `-backend-config="profile=..."`
- If you forget to reconfigure, Terraform may use the wrong state file, leading to unexpected behavior

## Provider Configuration

The main.tf uses two providers:

```hcl
# Default provider - changes based on aws_profile variable
provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

# Control plane provider - always points to control plane account
# Update this to match your control plane account profile
provider "aws" {
  region  = var.aws_region
  profile = "your-control-plane-profile"
  alias   = "control-plane-account"
}
```

**Important:** Update the `control-plane-account` provider's profile to match your control plane AWS profile.

During control plane deployment:
- Both providers point to control plane account
- Creates all control plane resources

During worker deployment:
- Default provider → worker account (creates worker resources)
- Control-plane-account provider → control plane account (creates environment setup machine, updates cross-account policy)

## Troubleshooting

### "Access Denied" when assuming role
- Verify the trust relationship is correctly set on the worker account role
- Verify the AssumeRole policy is correctly set on the control plane role
- Ensure both `aws_account_id` and `aws_worker_account_id` are correctly set in variables.tfvars
- Check IAM role propagation (may take a few seconds after creation)

### "Security group not found" errors
- This happens when resources reference security groups across accounts
- Solution: Set `workers_in_control_plane = false` to prevent cross-account security group rules
- Ensure security groups are created in the correct VPC

### "Module output not found" errors
- This happens when a module with count is not created but its output is referenced
- Check that conditional logic matches: `install_control_plane`, `install_workers`, `workers_in_control_plane`
- Verify module references use `[0]` indexing when module has a count

### State conflicts
- Each deployment should use a separate state file (see State Management section)
- Use different `key` values in backend configuration for control plane vs worker deployments
- Always run `terraform init -reconfigure` when switching between deployments
- If you accidentally use the wrong state file, resources may be recreated or destroyed

### Redis URL required for worker deployment
- When deploying workers in a separate account (`workers_in_control_plane = false`), you must provide the Redis URL
- Get the Redis URL from the control plane deployment output
- Set it in variables.tfvars: `redis_url = "redis://your-redis-endpoint:6379"`
