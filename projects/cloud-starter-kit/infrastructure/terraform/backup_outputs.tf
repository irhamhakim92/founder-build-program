output "backup_policy_id" {
  description = "AWS Data Lifecycle Manager policy used for automated Cloud Starter Kit backups."
  value       = aws_dlm_lifecycle_policy.web_daily.id
}
