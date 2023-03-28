output "roi_sg" {
  value = aws_security_group.valohai_sg_roi
}

output "workers_sg" {
  value = aws_security_group.valohai_sg_workers
}

output "queue_sg" {
  value = aws_security_group.valohai_sg_queue.id
}