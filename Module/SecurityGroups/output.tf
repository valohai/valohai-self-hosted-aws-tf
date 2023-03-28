output "roi_sg" {
  value = aws_security_group.valohai_sg_roi.id
}

output "workers_sg" {
  value = aws_security_group.valohai_sg_workers.id
}

output "queue_sg" {
  value = aws_security_group.valohai_sg_queue.id
}