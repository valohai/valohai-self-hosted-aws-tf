output "security_group_id" {
  value = aws_security_group.valohai_sg_roi.id
}

output "instance_id" {
  value = aws_instance.valohai_roi.id
}
