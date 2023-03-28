output "valohai_queue_public_ip" {
  value = aws_eip.valohai_ip_roi.public_ip
}

output "valohai_queue_private_ip" {
  value = aws_instance.valohai_roi.private_ip
}