resource "aws_lb" "valohai_nb_lb" {
  #checkov:skip=CKV2_AWS_28:Ensure public facing ALB are protected by WAF
  #checkov:skip=CKV2_AWS_20:Allow using HTTP only on ALB for sample purposes
  #checkov:skip=CKV_AWS_91:Ensure the ELBv2 (Application/Network) has access logging enabled
  name                       = "dev-valohai-alb-notebook"
  load_balancer_type         = "application"
  internal                   = false
  subnets                    = var.lb_subnet_ids
  security_groups            = [aws_security_group.valohai_sg_nb_lb.id]
  enable_deletion_protection = true
  drop_invalid_header_fields = true

}

resource "aws_lb_target_group" "valohai_notebook" {
  #checkov:skip=CKV_AWS_261:Ensure HTTP HTTPS Target group defines Healthcheck
  port     = 7200
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    enabled = true
  }
}

resource "aws_lb_listener" "https_notebook" {
  #checkov:skip=CKV_AWS_2:Don't ensure protocol is HTTPS for example purposes
  #checkov:skip=CKV_AWS_103:Don't redirect HTTP to HTTPS for example purposes
  load_balancer_arn = aws_lb.valohai_nb_lb.arn
  port              = "7200"
  protocol          = "HTTPS"
  certificate_arn   = var.notebook_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.valohai_notebook.arn
  }
}


resource "aws_security_group" "valohai_sg_nb_lb" {
  #checkov:skip=CKV_AWS_260:Allow port 80 for example purposes
  name        = "dev-valohai-sg-nb-alb"
  description = "for Valohai ELB"

  vpc_id = var.vpc_id

  ingress {
    description = "for ELB"
    from_port   = 7200
    to_port     = 7200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "valohai_sg_nb_lb",
  }
}

resource "aws_lb_target_group_attachment" "valohai_roi" {
  target_group_arn = aws_lb_target_group.valohai_notebook.id
  target_id        = var.valohai_roi_id
  port             = 7200
}

resource "aws_security_group_rule" "allow_nb_lb" {
  type                     = "ingress"
  from_port                = 7200
  to_port                  = 7200
  protocol                 = "tcp"
  description              = "Allow connection from Roi instance to the notebook loadbalancer"
  source_security_group_id = var.valohai_sg_roi
  security_group_id        = aws_security_group.valohai_sg_nb_lb.id
}

resource "aws_security_group_rule" "allow_nb_lb_on_roi" {
  type                     = "ingress"
  from_port                = 7200
  to_port                  = 7200
  protocol                 = "tcp"
  description              = "Allow connection for the loadbalancer on the Roi instance "
  source_security_group_id = aws_security_group.valohai_sg_nb_lb.id
  security_group_id        = var.valohai_sg_roi
}

resource "aws_security_group_rule" "allow_nb_workers_on_roi" {
  type                     = "ingress"
  from_port                = 7000
  to_port                  = 7000
  protocol                 = "tcp"
  description              = "Allow connection for the workers on the Roi instance "
  source_security_group_id = var.valohai_sg_workers
  security_group_id        = var.valohai_sg_roi
}
