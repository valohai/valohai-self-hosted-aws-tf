terraform {
  required_version = "1.12.1"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region

  default_tags {
    tags = {
      ProvisionedUsing = "Terraform"
      valohai          = "1"
    }
  }
}

# Configure the AWS Provider for control plane
provider "aws" {
  region  = "us-east-1"
  profile = ""
  alias   = "control-plane-account"

  default_tags {
    tags = {
      ProvisionedUsing = "Terraform"
      valohai          = "1"
    }
  }
}

module "IAM_Master" {
  source = "./Module/IAM/Master"

  aws_profile                = var.aws_profile
  aws_region                 = var.aws_region
  aws_account_id             = var.install_workers && !var.workers_in_control_plane ? var.aws_worker_account_id : var.aws_account_id
  s3_bucket_name             = var.s3_bucket_name
  enable_cross_account_trust = var.install_workers && !var.workers_in_control_plane
  control_plane_account_id   = var.aws_account_id # Control plane account ID

  depends_on = [module.IAM_Workers]
}

# Add AssumeRole permission to control plane's IAM Master role
# Only created when workers are in a different account
module "IAM_Master_CrossAccount_Policy" {
  source = "./Module/IAM/Master-CrossAccount-Policy"

  providers = {
    aws = aws.control-plane-account
  }

  count = var.install_workers && !var.workers_in_control_plane ? 1 : 0

  worker_account_id = var.aws_worker_account_id
}

module "IAM_Workers" {
  source = "./Module/IAM/Workers"
}

module "IAM_S3" {
  source = "./Module/IAM/S3"

  providers = {
    aws = aws.control-plane-account
  }

  count = var.install_control_plane ? 1 : 0

  aws_account_id = var.aws_account_id
  s3_bucket_name = var.s3_bucket_name

  depends_on = [
    module.IAM_Master
  ]
}

module "Database" {
  source = "./Module/Postgres"

  providers = {
    aws = aws.control-plane-account
  }

  count = var.install_control_plane ? 1 : 0

  aws_account_id = var.aws_account_id
  vpc_id         = var.vpc_id
  db_subnet_ids  = var.db_subnet_ids
}

module "Redis" {
  source = "./Module/Redis"

  providers = {
    aws = aws.control-plane-account
  }

  count = var.install_control_plane ? 1 : 0

  vpc_id           = var.vpc_id
  cache_subnet_ids = var.db_subnet_ids
}

module "S3" {
  source = "./Module/S3"

  providers = {
    aws = aws.control-plane-account
  }

  count = var.install_control_plane ? 1 : 0

  domain         = var.domain
  aws_account_id = var.aws_account_id
  s3_bucket_name = var.s3_bucket_name
  s3_logs_name   = var.s3_logs_name

  depends_on = [module.IAM_S3]
}

module "LB" {
  source = "./Module/LB"

  providers = {
    aws = aws.control-plane-account
  }

  count = var.install_control_plane ? 1 : 0

  aws_account_id  = var.aws_account_id
  vpc_id          = var.vpc_id
  lb_subnet_ids   = var.lb_subnet_ids
  certificate_arn = var.certificate_arn
  s3_logs_name    = var.s3_logs_name
}

module "EC2" {
  source = "./Module/EC2"

  providers = {
    aws = aws.control-plane-account
  }

  count = var.install_control_plane ? 1 : 0

  aws_account_id     = var.aws_account_id
  ec2_key            = var.ec2_key
  region             = var.aws_region
  vpc_id             = var.vpc_id
  roi_subnet_id      = var.roi_subnet_id
  lb_target_group_id = module.LB[0].target_group_id
  lb_sg              = module.LB[0].security_group_id
  s3_bucket_name     = var.s3_bucket_name
  s3_kms_key         = module.S3[0].kms_key
  environment_name   = var.environment_name
  organization       = var.organization
  db_url             = module.Database[0].database_url
  db_password        = module.Database[0].database_password
  redis_url          = module.Redis[0].redis_url
  domain             = var.domain
  ami_id             = var.ami_id
  depends_on         = [module.Database, module.IAM_Master, module.Redis, module.S3, module.LB]
}


locals {
  # Flatten environments × on-demand instance types into a map keyed by "env_key-instance_type"
  worker_asg_configs = {
    for combo in flatten([
      for env_key, env in var.environments : [
        for instance_type in env.aws_instance_types : {
          key           = "${env_key}-${instance_type}"
          env_key       = env_key
          env           = env
          instance_type = instance_type
        }
      ]
    ]) : combo.key => combo
  }

  # Flatten environments × spot instance types, skipping envs with add_spot_instances = false
  worker_spot_configs = {
    for combo in flatten([
      for env_key, env in var.environments : [
        for instance_type in env.add_spot_instances ? env.aws_spot_instance_types : [] : {
          key           = "${env_key}-${instance_type}"
          env_key       = env_key
          env           = env
          instance_type = instance_type
        }
      ]
    ]) : combo.key => combo
  }
}

module "Workers_ASG" {
  source = "./Module/Workers/ASG"

  for_each = var.install_workers ? local.worker_asg_configs : {}

  subnet_ids            = var.worker_subnet_ids
  instance_type         = each.value.instance_type
  region                = var.aws_region
  redis_url             = each.value.env.redis_url != "" ? each.value.env.redis_url : length(module.Redis) > 0 ? module.Redis[0].redis_url : var.redis_url
  ami                   = "" # Leave empty for default
  env_asg_prefix        = each.value.env.env_asg_prefix
  env_queue_prefix      = each.value.env.env_queue_prefix
  valohai_sg_workers_id = module.Workers_Security-groups[0].worker_security_group_id
  instance_profile      = module.IAM_Workers.worker_instance_profile_name
  key_name              = module.Workers_Security-groups[0].worker_key_name

  depends_on = [
    module.IAM_Workers, module.EC2, module.Workers_Security-groups
  ]
}

module "Workers_ASG-spots" {
  source = "./Module/Workers/ASG-spots"

  for_each = var.install_workers ? local.worker_spot_configs : {}

  subnet_ids            = var.worker_subnet_ids
  instance_type         = each.value.instance_type
  region                = var.aws_region
  redis_url             = each.value.env.redis_url != "" ? each.value.env.redis_url : length(module.Redis) > 0 ? module.Redis[0].redis_url : var.redis_url
  ami                   = "" # Leave empty for default
  env_asg_prefix        = each.value.env.env_asg_prefix
  env_queue_prefix      = each.value.env.env_queue_prefix
  valohai_sg_workers_id = module.Workers_Security-groups[0].worker_security_group_id
  instance_profile      = module.IAM_Workers.worker_instance_profile_name
  key_name              = module.Workers_Security-groups[0].worker_key_name

  depends_on = [
    module.IAM_Workers, module.EC2, module.Workers_Security-groups
  ]
}

module "Workers_Security-groups" {
  source = "./Module/Workers/Security-groups"

  count = var.install_workers ? 1 : 0

  vpc_id                  = var.worker_vpc_id
  roi_sg_id               = var.install_control_plane ? module.EC2[0].roi_security_group_id : ""
  ec2_key                 = var.ec2_key
  create_roi_ingress_rule = var.workers_in_control_plane
}

module "Workers_Valohai-environments-SecurityGroup" {
  source = "./Module/Workers/Valohai-environments-SecurityGroup"

  providers = {
    aws = aws.control-plane-account
  }

  count = var.install_control_plane ? 1 : 0

  vpc_id = var.vpc_id
}

module "Workers_Valohai-environments" {
  source = "./Module/Workers/Valohai-environments"

  providers = {
    aws = aws.control-plane-account
  }

  for_each = var.install_workers ? var.environments : {}

  aws_region              = var.aws_region
  aws_account_id          = var.aws_account_id
  aws_worker_account_id   = var.aws_worker_account_id
  vpc_id                  = var.worker_vpc_id
  roi_subnet_id           = var.roi_subnet_id
  env_setup_sg_id         = var.workers_in_control_plane ? module.Workers_Valohai-environments-SecurityGroup[0].security_group_id : ""
  redis_url               = each.value.redis_url != "" ? each.value.redis_url : length(module.Redis) > 0 ? module.Redis[0].redis_url : var.redis_url
  domain                  = var.domain
  ami_id                  = var.ami_id
  env_owner_id            = each.value.env_owner_id
  env_name_prefix         = each.value.env_name_prefix
  env_asg_prefix          = each.value.env_asg_prefix
  env_queue_prefix        = each.value.env_queue_prefix
  aws_instance_types      = each.value.aws_instance_types
  aws_spot_instance_types = each.value.aws_spot_instance_types
  add_spot_instances      = each.value.add_spot_instances
  depends_on              = [module.Redis, module.EC2, module.Workers_Valohai-environments-SecurityGroup]
}
