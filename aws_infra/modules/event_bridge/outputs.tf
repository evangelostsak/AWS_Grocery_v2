output "event_rule_name" {
    description = "Name of the EventBridge rule for S3 upload triggering Step Function"
    value       = aws_cloudwatch_event_rule.s3_upload_event.name
}
