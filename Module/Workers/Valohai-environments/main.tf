terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# Temporary machine for setting up environment in Valohai
resource "aws_instance" "valohai_environments_setup" {
  ami                    = var.ami_id
  instance_type          = "t3.medium"
  key_name               = "dev-valohai-key-valohai"
  vpc_security_group_ids = [var.env_setup_sg_id]
  subnet_id              = var.roi_subnet_id
  iam_instance_profile   = "dev-valohai-iami-master"
  monitoring             = true
  ebs_optimized          = true
  user_data = templatefile("${path.module}/config/user_data.sh", {
    url_base                = var.domain
    region                  = var.aws_region
    aws_account_id          = var.aws_account_id
    aws_worker_account_id   = var.aws_worker_account_id
    redis_url               = var.redis_url
    module_path             = path.module
    worker_vpc_id           = var.vpc_id
    organization            = var.env_owner_id
    env_name_prefix         = var.env_name_prefix
    env_asg_prefix          = var.env_asg_prefix
    env_queue_prefix        = var.env_queue_prefix
    aws_instance_types      = indent(2, yamlencode(var.aws_instance_types))
    aws_spot_instance_types = var.add_spot_instances ? indent(2, yamlencode(formatlist("%s.spot", var.aws_spot_instance_types))) : ""
  })
  user_data_replace_on_change = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  root_block_device {
    volume_type = "gp2"
    volume_size = 32
    encrypted   = true
  }

  tags = {
    Name = "dev-valohai-ec2-environment-setup",
  }

  lifecycle {
    create_before_destroy = false
  }

}
