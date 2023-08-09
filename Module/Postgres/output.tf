output "database_url" {
  value = aws_db_instance.valohai_roidb.address
}

output "database_password" {
  value     = aws_db_instance.valohai_roidb.password
  sensitive = true
}
