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

source "amazon-ebs" "valohai_roi" {
  profile = var.aws_profile
  region  = var.region

  ami_name             = "valohai-roi-${local.timestamp}"
  instance_type        = "m5.xlarge"
  iam_instance_profile = "MasterInstanceProfile"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477", "450886142693"] # Which AWS Account can access this image
  }
  ssh_username = "ubuntu"
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
