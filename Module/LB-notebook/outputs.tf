output "security_group_id" {
  value = aws_security_group.valohai_sg_nb_lb.id
}

output "target_group_id" {
  value = aws_lb_target_group.valohai_notebook.id
}
