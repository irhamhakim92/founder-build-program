output "web_instance_id" {
  description = "ID of the Cloud Starter Kit EC2 application host."
  value       = aws_instance.web.id
}

output "web_public_ip" {
  description = "Stable public IPv4 address of the application host."
  value       = aws_eip.web.public_ip
}

output "web_elastic_ip_allocation_id" {
  description = "Allocation ID of the application host Elastic IP."
  value       = aws_eip.web.id
}

output "web_public_dns" {
  description = "Public DNS name of the application host."
  value       = aws_instance.web.public_dns
}

output "web_url" {
  description = "HTTP URL for the Cloud Starter Kit demonstration page."
  value       = "http://${aws_eip.web.public_ip}"
}

output "session_manager_command" {
  description = "AWS CLI command used to connect through Systems Manager."
  value       = "aws ssm start-session --target ${aws_instance.web.id} --region ${var.aws_region}"
}
