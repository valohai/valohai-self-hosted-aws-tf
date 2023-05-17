variable "region" {
  type    = string
  default = "eu-west-2"
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

source "amazon-ebs" "valohai_roi" {
  profile = var.aws_profile
  region  = var.region

  ami_name             = "valohai-roi-${local.timestamp}"
  instance_type        = "m5.xlarge"
  iam_instance_profile = "MasterInstanceProfile"
  ssh_username         = "ubuntu"

  source_ami_filter {
    filters = {
      name                = "ubuntu-pro-server/images/hvm-ssd/ubuntu-jammy-22.04-amd64-*" # CIS Hardened Ubuntu 22.04
      #name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-*"            # Standard Ubuntu 22.04
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"] # Canonical
  }

  ami_users = [
    "450886142693", # Valohai Sandbox
    "790096077483" # PRH
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
  sources = ["source.amazon-ebs.valohai_roi"]

  # Copy default roi.config
  provisioner "file" {
    source      = "config/roi.config"
    destination = "/tmp/roi.config"
  }

  # Copy default roi.service file
  provisioner "file" {
    source      = "config/roi.service"
    destination = "/tmp/roi.service"
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
