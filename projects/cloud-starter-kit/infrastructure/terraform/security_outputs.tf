output "web_security_group_id" {
  description = "ID of the security group assigned to the web server."
  value       = aws_security_group.web.id
}
