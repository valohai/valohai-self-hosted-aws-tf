# Get the AMI for bastion instance
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Load public key
resource "aws_key_pair" "valohai_bastion_key" {
  key_name   = "valohai_bastion_${var.region}"
  public_key = file(var.ec2_key)

  tags = {
    Name = "valohai_bastion_key",
  }
}

# Valohai bastion instance
resource "aws_instance" "valohai_bastion" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.small"
  iam_instance_profile   = "ValohaiWorkerProfile"
  key_name               = aws_key_pair.valohai_bastion_key.id
  vpc_security_group_ids = [aws_security_group.valohai_sg_bastion.id]
  subnet_id              = var.bastion_subnet_id
  monitoring             = true
  ebs_optimized          = true

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

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = aws_instance.valohai_bastion.public_ip
    private_key = file(var.ec2_key)
  }

  tags = {
    Name = "valohai_bastion",
  }
}

resource "aws_security_group" "valohai_sg_bastion" {
  name        = "valohai_sg_bastion"
  description = "for Valohai Bastion"

  vpc_id = var.vpc_id

  ingress {
    description = "for Valohai SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["3.251.38.215/32"] # Valohai Bastion
  }

  egress {
    description = "Allow outbound access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "valohai_sg_bastion"
  }
}