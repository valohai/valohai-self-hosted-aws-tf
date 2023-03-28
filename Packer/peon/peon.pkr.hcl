variable "region" {
  type    = string
  default = "us-east-1"
}

variable "aws_profile" {
  type = string
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

packer {
  required_plugins {
    docker = {
      version = "= 1.0.1"
      source  = "github.com/hashicorp/docker"
    }
  }
}

source "amazon-ebs" "valohai_peon" {
  profile = var.aws_profile
  region  = var.region

  ami_name             = "valohai-peon-${local.timestamp}"
  instance_type        = "p2.xlarge"
  iam_instance_profile = "MasterInstanceProfile"
  ssh_username         = "ubuntu"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"] # Canonical
  }

  ami_users = ["450886142693"] # Which AWS Account can access this image
}

build {
  sources = ["source.amazon-ebs.valohai_peon"]

  # Copy default peon.config
  provisioner "file" {
    source      = "config/peon.config"
    destination = "/tmp/peon.config"
  }

  # Copy default peon.service files
  provisioner "file" {
    source      = "config/peon.service"
    destination = "/tmp/peon.service"
  }

  provisioner "file" {
    source      = "config/peon-clean.service"
    destination = "/tmp/peon-clean.service"
  }

  provisioner "file" {
    source      = "config/peon-clean.timer"
    destination = "/tmp/peon-clean.timer"
  }

  # Copy default docker prune service files
  
  provisioner "file" {
    source      = "config/docker-prune.service"
    destination = "/tmp/docker-prune.service"
  }
  
  provisioner "file" {
    source      = "config/docker-prune.timer"
    destination = "/tmp/docker-prune.timer"
  }

  # Copy default AWS credentials file
  provisioner "file" {
    source      = "config/credentials"
    destination = "/tmp/credentials"
  }

  # Run setup script
  provisioner "shell" {
    script = "setup.sh"
  }

}
