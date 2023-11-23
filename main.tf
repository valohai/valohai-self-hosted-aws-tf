terraform {
  required_version = "1.4.6"
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

module "IAM_Master" {
  source = "./Module/IAM/Master"

  aws_region     = var.aws_region
  aws_account_id = var.aws_account_id
  s3_bucket_name = var.s3_bucket_name

  depends_on = [module.IAM_Workers]
}

module "IAM_Workers" {
  source = "./Module/IAM/Workers"
}

module "IAM_S3" {
  source = "./Module/IAM/S3"

  aws_account_id = var.aws_account_id
  s3_bucket_name = var.s3_bucket_name

  depends_on = [
    module.IAM_Master
  ]
}

module "Database" {
  source = "./Module/Postgres"

  aws_account_id = var.aws_account_id
  vpc_id         = var.vpc_id
  db_subnet_ids  = var.db_subnet_ids
}

module "Redis" {
  source = "./Module/Redis"

  vpc_id           = var.vpc_id
  cache_subnet_ids = var.db_subnet_ids
}

module "S3" {
  source         = "./Module/S3"
  domain         = var.domain
  aws_account_id = var.aws_account_id
  s3_bucket_name = var.s3_bucket_name
  s3_logs_name   = var.s3_logs_name

  depends_on = [module.IAM_S3]
}

module "LB" {
  source = "./Module/LB"

  aws_account_id  = var.aws_account_id
  vpc_id          = var.vpc_id
  lb_subnet_ids   = var.lb_subnet_ids
  certificate_arn = var.certificate_arn
  s3_logs_name    = var.s3_logs_name
}

module "EC2" {
  source             = "./Module/EC2"
  aws_account_id     = var.aws_account_id
  ec2_key            = var.ec2_key
  region             = var.aws_region
  vpc_id             = var.vpc_id
  roi_subnet_id      = var.roi_subnet_id
  lb_target_group_id = module.LB.target_group_id
  lb_sg              = module.LB.security_group_id
  s3_bucket_name     = var.s3_bucket_name
  s3_kms_key         = module.S3.kms_key
  environment_name   = var.environment_name
  organization       = var.organization
  db_url             = module.Database.database_url
  db_password        = module.Database.database_password
  redis_url          = module.Redis.redis_url
  domain             = var.domain
  ami_id             = var.ami_id
  aws_instance_types = var.aws_instance_types
  aws_spot_instance_types = var.aws_spot_instance_types
  add_spot_instances = var.add_spot_instances
  depends_on = [module.Database, module.IAM_Master, module.Redis, module.S3, module.LB]
}


module "ASG" {
  source = "./Module/ASG"

  for_each = toset(var.aws_instance_types)

  vpc_id           = var.vpc_id
  subnet_ids       = var.worker_subnet_ids
  instance_type    = each.key
  region           = var.aws_region
  redis_url        = module.Redis.redis_url
  ami              = "" # Leave empty for default
  worker_sg_id     = module.EC2.worker_security_group_id
  instance_profile = module.IAM_Workers.worker_instance_profile_name

  depends_on = [
    module.IAM_Workers, module.EC2
  ]
}

module "ASG-spots" {
  #count  = var.add_spot_instances ? toset(var.aws_spot_instance_types) : 0
  source = "./Module/ASG-spots"

  for_each = var.add_spot_instances ? toset(var.aws_spot_instance_types) : []

  vpc_id           = var.vpc_id
  subnet_ids       = var.worker_subnet_ids
  instance_type    = each.key
  region           = var.aws_region
  redis_url        = module.Redis.redis_url
  ami              = "" # Leave empty for default
  worker_sg_id     = module.EC2.worker_security_group_id
  instance_profile = module.IAM_Workers.worker_instance_profile_name

  depends_on = [
    module.IAM_Workers, module.EC2
  ]
}
