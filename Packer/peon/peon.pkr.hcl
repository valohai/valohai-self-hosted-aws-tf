variable "region" {
  type    = string
  default = "eu-west-1"
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
    amazon = {
      version = ">= 1.2.2" # preferably "~> 1.2.0" for latest patch version
      source = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "valohai_peon" {
  profile = var.aws_profile
  region  = var.region

  ami_name      = "valohai-peon-${local.timestamp}"
  imds_support  = "v2.0"
  instance_type = "p2.xlarge"
  ssh_username  = "ubuntu"

  metadata_options {
    http_endpoint = "enabled"
    http_tokens = "required"
    http_put_response_hop_limit = 2
  }

  launch_block_device_mappings {
    device_name = "/dev/sda1"
    delete_on_termination = true
    volume_size = 20
    volume_type = "gp2"
  }
  launch_block_device_mappings { 
    device_name = "/dev/sdb"
    no_device = true  
  }
  launch_block_device_mappings {  
    device_name = "/dev/sdc" 
    no_device = true  
  }

  source_ami_filter {
    filters = {
      name                = "ubuntu-pro-server/images/hvm-ssd/ubuntu-focal-20.04-amd64-*" # CIS Hardened Ubuntu 22.04
      #name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-*"            # Standard Ubuntu 22.04
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"] # Canonical
  }

  # Which AWS Account can access this image
  ami_users = [
    "450886142693", # Valohai Sandbox
    "790272426079",  # BSCI
    "790096077483", # PRH
    "682562199936", # Continental
  ]

  ami_regions = [
    "ap-northeast-1",
    "ap-northeast-2",
    "ap-northeast-3",
    "ap-south-1",
    "ap-southeast-1",
    "ap-southeast-2",
    "ca-central-1",
    "eu-central-1",
    "eu-west-1",
    "eu-west-2",
    "eu-west-3",
    "eu-north-1",
    "sa-east-1",
    "us-east-1",
    "us-east-2",
    "us-west-1",
    "us-west-2"
  ]
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
