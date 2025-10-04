output "sns_topic_arn" {
	description = "ARN of the SNS topic used for alert notifications"
	value       = aws_sns_topic.alerts.arn
}

output "cpu_alarm_name" {
	description = "Name of the high CPU CloudWatch alarm"
	value       = aws_cloudwatch_metric_alarm.high_cpu.alarm_name
}

output "disk_alarm_name" {
	description = "Name of the disk usage CloudWatch alarm"
	value       = aws_cloudwatch_metric_alarm.disk_usage.alarm_name
}

output "step_function_log_group_arn" {
  description = "ARN of the Step Function CloudWatch log group"
  value       = aws_cloudwatch_log_group.step_function_log_group.arn
}

