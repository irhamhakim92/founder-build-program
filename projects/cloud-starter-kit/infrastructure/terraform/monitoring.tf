resource "aws_sns_topic" "alerts" {
  name = "${local.name_prefix}-alerts"

  tags = {
    Name = "${local.name_prefix}-alerts"
  }
}

resource "aws_cloudwatch_metric_alarm" "web_status_check_failed" {
  alarm_name        = "${local.name_prefix}-web-status-check-failed"
  alarm_description = "Alerts when the Cloud Starter Kit EC2 instance fails an AWS status check."

  namespace   = "AWS/EC2"
  metric_name = "StatusCheckFailed"

  statistic = "Maximum"
  period    = 300

  evaluation_periods  = 2
  datapoints_to_alarm = 2

  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    InstanceId = aws_instance.web.id
  }

  alarm_actions = [
    aws_sns_topic.alerts.arn,
  ]

  ok_actions = [
    aws_sns_topic.alerts.arn,
  ]

  insufficient_data_actions = []

  treat_missing_data = "missing"

  tags = {
    Name = "${local.name_prefix}-web-status-check-failed"
  }
}

resource "aws_cloudwatch_metric_alarm" "web_high_cpu" {
  alarm_name        = "${local.name_prefix}-web-high-cpu"
  alarm_description = "Alerts when the Cloud Starter Kit EC2 instance sustains high CPU utilization."

  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"

  statistic = "Average"
  period    = 300

  evaluation_periods  = 2
  datapoints_to_alarm = 2

  threshold           = 80
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    InstanceId = aws_instance.web.id
  }

  alarm_actions = [
    aws_sns_topic.alerts.arn,
  ]

  ok_actions = [
    aws_sns_topic.alerts.arn,
  ]

  insufficient_data_actions = []

  treat_missing_data = "missing"

  tags = {
    Name = "${local.name_prefix}-web-high-cpu"
  }
}

