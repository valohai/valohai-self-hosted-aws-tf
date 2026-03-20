output "security_group_id" {
  description = "ID of the environment setup security group"
  value       = aws_security_group.valohai_sg_env_setup.id
}
