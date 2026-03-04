output "worker_security_group_id" {
  value = aws_security_group.valohai_sg_workers.id
}

output "worker_key_name" {
  value       = aws_key_pair.valohai_worker_key.key_name
  description = "Key pair name for worker instances"
}
