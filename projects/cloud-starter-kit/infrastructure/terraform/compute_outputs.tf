output "web_instance_id" {
  description = "ID of the Cloud Starter Kit EC2 application host."
  value       = aws_instance.web.id
}

output "web_public_ip" {
  description = "Public IPv4 address of the application host."
  value       = aws_instance.web.public_ip
}

output "web_public_dns" {
  description = "Public DNS name of the application host."
  value       = aws_instance.web.public_dns
}

output "web_url" {
  description = "HTTP URL for the Cloud Starter Kit demonstration page."
  value       = "http://${aws_instance.web.public_ip}"
}

output "session_manager_command" {
  description = "AWS CLI command used to connect through Systems Manager."
  value       = "aws ssm start-session --target ${aws_instance.web.id} --region ${var.aws_region}"
}
