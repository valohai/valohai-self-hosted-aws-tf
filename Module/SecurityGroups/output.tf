output "roi_sg" {
  value = aws_security_group.valohai_sg_roi
}

output "elb_sg" {
  value = aws_security_group.valohai_sg_elb
}

output "workers_sg" {
  value = aws_security_group.valohai_sg_workers
}

output "queue_sg" {
  value = aws_security_group.valohai_sg_queue.id
}
