terraform {

  required_version = "1.4.2"

  required_providers {
    aws = {
      source = "hashicorp/aws"

    }
  }
}

provider "aws" {
  profile = var.aws_profile
  region = var.region
}


module "Database" {
  source = "./Module/Postgres"

  vpc_id             = var.vpc_id
  db_subnet_ids      = var.db_subnet_ids
  security_group_ids = [module.SecurityGroups.roi_sg, module.SecurityGroups.workers_sg]

}

module "Redis" {
  source = "./Module/Redis"

  cache_subnet_ids   = var.db_subnet_ids
  security_group_ids = [module.SecurityGroups.queue_sg]

  depends_on = [module.SecurityGroups]
}

module "IAM_Master" {
  source     = "./Module/IAM/Master"
  depends_on = [module.IAM_Workers]
}

module "IAM_Workers" {
  source = "./Module/IAM/Workers"
}

module "IAM_S3" {
  source = "./Module/IAM/S3"

  depends_on = [
    module.IAM_Master
  ]
}

module "S3" {
  source = "./Module/S3"

  depends_on = [module.IAM_S3]
}

module "SecurityGroups" {
  source = "./Module/SecurityGroups"

  vpc_id = var.vpc_id
}

module "EC2" {
  source            = "./Module/EC2"
  ec2_key           = var.ec2_key
  region            = var.region
  subnet_id         = var.public_subnet_id
  security_group_id = module.SecurityGroups.roi_sg
  environment_name  = var.environment_name
  db_url            = module.Database.database_url
  db_password       = module.Database.database_password
  redis_url         = module.Redis.redis_url

  depends_on = [module.Database, module.IAM_Master, module.Redis]
}
