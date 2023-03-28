terraform {

  required_version = "1.4.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

resource "aws_elasticache_subnet_group" "valohai_queue_subnet" {
  name       = "valohai-queue-subnet"
  subnet_ids = var.cache_subnet_ids

}

resource "aws_elasticache_cluster" "valohai_queue" {
  cluster_id      = "valohai-queue"
  engine          = "redis"
  node_type       = "cache.m4.xlarge"
  num_cache_nodes = 1
  engine_version  = "6.2"
  port            = 6379

  security_group_ids = var.security_group_ids
  subnet_group_name  = aws_elasticache_subnet_group.valohai_queue_subnet.name
}