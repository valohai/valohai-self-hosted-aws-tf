output "worker_role" {
  value = aws_iam_role.valohai_worker_role.arn
}

output "worker_instance_profile_name" {
  value = aws_iam_instance_profile.valohai_worker_profile.name
}
