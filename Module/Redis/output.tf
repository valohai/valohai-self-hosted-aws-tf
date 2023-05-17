output "redis_url" {
  value = aws_elasticache_cluster.valohai_queue.cache_nodes[0].address
}
