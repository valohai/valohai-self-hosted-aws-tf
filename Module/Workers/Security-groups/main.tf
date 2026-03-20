# Load public key for worker instances
resource "aws_key_pair" "valohai_worker_key" {
  key_name   = "dev-valohai-key-workers"
  public_key = file(var.ec2_key)

  tags = {
    Name = "dev-valohai-key-workers",
  }
}

# Create worker security group
resource "aws_security_group" "valohai_sg_workers" {
  #checkov:skip=CKV2_AWS_5:Ensure security groups are attached to another resource
  name        = "dev-valohai-sg-workers"
  description = "for Valohai workers"

  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound access"
  }

  tags = {
    Name = "dev-valohai-sg-workers",
  }
}

# Allow worker access on the Valohai app (only when workers are in same account as ROI)
resource "aws_security_group_rule" "allow_workers_ingress" {
  count = var.create_roi_ingress_rule ? 1 : 0

  type                     = "ingress"
  from_port                = 8000
  to_port                  = 8000
  protocol                 = "tcp"
  description              = "For workers"
  source_security_group_id = aws_security_group.valohai_sg_workers.id
  security_group_id        = var.roi_sg_id
}
