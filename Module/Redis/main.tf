data "aws_vpc" "valohai_vpc" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

resource "aws_elasticache_subnet_group" "valohai_queue_subnet" {
  name       = "valohai-queue-subnet"
  subnet_ids = var.cache_subnet_ids

}

resource "aws_elasticache_cluster" "valohai_queue" {
  cluster_id               = "valohai-queue"
  engine                   = "redis"
  node_type                = "cache.m4.xlarge"
  num_cache_nodes          = 1
  engine_version           = "6.2"
  port                     = 6379
  snapshot_retention_limit = 5

  security_group_ids = [aws_security_group.valohai_sg_queue.id]
  subnet_group_name  = aws_elasticache_subnet_group.valohai_queue_subnet.name
}

resource "aws_security_group" "valohai_sg_queue" {
  name        = "valohai_sg_queue"
  description = "for Valohai Queue"

  vpc_id = var.vpc_id

  ingress {
    description = "for Redis"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.valohai_vpc.cidr_block]
  }

  tags = {
    Name = "valohai_sg_queue",
  }
}
