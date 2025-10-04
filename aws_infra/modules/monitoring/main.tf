############################################
# MONITORING MODULE - CloudWatch & SNS
############################################

resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-${var.environment}-alerts"
  tags = merge(local.merged_tags, {
    Name = "${var.project_name}-${var.environment}-alerts"
  })
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.cpu_period
  statistic           = "Average"
  threshold           = var.cpu_threshold
  alarm_description   = "High average CPU utilization"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
  dimensions          = { AutoScalingGroupName = var.asg_name }
  tags = merge(local.merged_tags, {
    Name = "${var.project_name}-${var.environment}-high-cpu"
  })
}

resource "aws_cloudwatch_metric_alarm" "disk_usage" {
  alarm_name          = "${var.project_name}-${var.environment}-disk-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = var.disk_period
  statistic           = "Average"
  threshold           = var.disk_threshold
  alarm_description   = "Disk usage percentage too high"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
  dimensions = {
    AutoScalingGroupName = var.asg_name
    Filesystem           = var.disk_filesystem
    MountPath            = var.disk_mount_path
  }
  tags = merge(local.merged_tags, {
    Name = "${var.project_name}-${var.environment}-disk-usage"
  })
}

############################################
# Cloudwatch - LOG GROUPS 
############################################

# Lambda log group
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/db_populator"
  retention_in_days = 7
  tags              = merge(local.merged_tags, { Name = "${var.project_name}-${var.environment}-lambda-log" })
}

# Step Function log group
resource "aws_cloudwatch_log_group" "step_function_log_group" {
  name              = "/aws/vendedlogs/states/db-restore-step-function"
  retention_in_days = 7
  tags              = merge(local.merged_tags, { Name = "${var.project_name}-${var.environment}-sfn-log" })
}

# Resource policy to allow Step Functions to write to CloudWatch Logs
resource "aws_cloudwatch_log_resource_policy" "step_function_log_policy" {
  policy_name = "StepFunctionLogPolicy"
  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "states.amazonaws.com" }
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogDelivery",
          "logs:GetLogDelivery",
          "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:ListLogDeliveries"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

