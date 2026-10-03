output "github_deploy_role_arn" {
  description = "IAM role ARN used by GitHub Actions to deploy the Cloud Starter Kit application."
  value       = aws_iam_role.github_actions_deploy.arn
}
