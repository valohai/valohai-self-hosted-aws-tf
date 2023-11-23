# Get the AMI for peon instance
data "aws_ami" "valohai" {
  most_recent = true

  filter {
    name   = "name"
    values = ["valohai-peon-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["635691382966"] # Valohai Customer
}

resource "aws_launch_template" "valohai_worker_lt" {
  name_prefix            = "valohai-lt-worker-${var.instance_type}-spot"
  image_id               = (var.ami == "") ? data.aws_ami.valohai.id : var.ami
  instance_type          = var.instance_type
  key_name               = "dev-valohai-key-valohai"
  user_data              = base64encode(templatefile("${path.module}/peon/userdata", { queue_name = "${var.region}-${var.instance_type}", redis_url = "redis://:@${var.redis_url}:6379" }))
  update_default_version = true
  ebs_optimized          = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  network_interfaces {
    associate_public_ip_address = var.assign_public_ip
    security_groups             = [var.worker_sg_id]
    delete_on_termination       = true
  }

  iam_instance_profile {
    name = var.instance_profile
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_type           = "gp2"
      delete_on_termination = true
      volume_size           = var.ebs_disk_size
      encrypted             = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      "Role"             = "ValohaiWorker"
      "ProvisionedUsing" = "Terraform"
      "valohai"          = "1"
    }
  }
}

resource "aws_autoscaling_group" "valohai_worker_asg" {
  name                      = "dev-valohai-asg-worker-${var.instance_type}-spot"
  max_size                  = 100
  min_size                  = 0
  health_check_grace_period = 0
  health_check_type         = "EC2"
  desired_capacity          = 0
  force_delete              = true
  vpc_zone_identifier       = var.subnet_ids
  default_cooldown          = 60

  termination_policies = ["ClosestToNextInstanceHour", "NewestInstance"]

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "capacity-optimized"
      spot_max_price                           = ""
    }

    launch_template {
      launch_template_specification {
        launch_template_id      = aws_launch_template.valohai_worker_lt.id
        version = "$Latest"
      }
    }
  }

  tag {
    key                 = "valohai"
    value               = 1
    propagate_at_launch = true
  }

  tag {
    key                 = "ProvisionedUsing"
    value               = "Terraform"
    propagate_at_launch = true
  }

}
