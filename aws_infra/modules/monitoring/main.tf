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
	dimensions = { AutoScalingGroupName = var.asg_name }
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

