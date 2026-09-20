output "alert_topic_arn" {
  description = "SNS topic ARN used for Cloud Starter Kit monitoring alerts."
  value       = aws_sns_topic.alerts.arn
}

output "monitoring_alarm_names" {
  description = "CloudWatch alarms protecting the Cloud Starter Kit application host."

  value = {
    status_check = aws_cloudwatch_metric_alarm.web_status_check_failed.alarm_name
    high_cpu     = aws_cloudwatch_metric_alarm.web_high_cpu.alarm_name
  }
}
