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
  region  = var.region
}

module "Database" {
  source = "./Module/Postgres"

  vpc_id             = var.vpc_id
  db_subnet_ids      = var.db_subnet_ids
  security_group_ids = [module.SecurityGroups.roi_sg.id, module.SecurityGroups.workers_sg.id]

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
  source                 = "./Module/EC2"
  ec2_key                = var.ec2_key
  region                 = var.region
  vpc_id                 = var.vpc_id
  elb_subnet_ids         = var.elb_subnet_ids
  roi_subnet_id          = var.roi_subnet_id
  roi_security_group_ids = [module.SecurityGroups.roi_sg.id]
  elb_security_group_ids = [module.SecurityGroups.elb_sg.id]
  environment_name       = var.environment_name
  db_url                 = module.Database.database_url
  db_password            = module.Database.database_password
  redis_url              = module.Redis.redis_url

  depends_on = [module.Database, module.IAM_Master, module.Redis]
}

module "ASG" {
  source = "./Module/ASG"

  for_each = toset(var.aws_instances_types)

  vpc_id            = var.vpc_id
  subnet_ids        = var.worker_subnet_ids
  security_group_id = module.SecurityGroups.workers_sg.id
  instance_type     = each.key
  region            = var.region
  redis_url         = module.Redis.redis_url
  assign_public_ip  = true
  ami               = "" # Leave empty for default

  depends_on = [
    module.SecurityGroups, module.IAM_Workers, module.EC2
  ]
}