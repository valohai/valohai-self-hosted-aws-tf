output "security_group_id" {
  value = aws_security_group.valohai_sg_lb.id
}

output "dns_name" {
  value = aws_lb.valohai_lb.dns_name
}

output "arn" {
  value = aws_lb.valohai_lb.arn
}

output "target_group_id" {
  value = aws_lb_target_group.valohai_roi.id
}

output "acm_certificate_domain_validation_options" {
  value = flatten(aws_acm_certificate.cert[*].domain_validation_options)
}
