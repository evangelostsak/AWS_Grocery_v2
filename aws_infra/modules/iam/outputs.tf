output "instance_profile_name" {
  description = "Name of the EC2 instance profile for attaching to launch template"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "ec2_role_arn" {
  description = "ARN of the EC2 IAM role"
  value       = aws_iam_role.ec2_role.arn
}

output "rds_monitoring_role_arn" {
  description = "ARN of the IAM role used for RDS enhanced monitoring"
  value       = aws_iam_role.rds_monitoring.arn
}

output "lambda_iam_role_arn" {
  description = "The ARN of the IAM role for Lambda"
  value       = aws_iam_role.lambda_role.arn
}

output "lambda_iam_role_name" {
  value       = aws_iam_role.lambda_role.name
  description = "The name of the IAM role."
}

output "sfn_role_arn" {
  description = "ARN of the Step Functions IAM role"
  value       = aws_iam_role.sfn_role.arn
}

output "eventbridge_role_arn" {
  description = "ARN of the EventBridge invocation role"
  value       = aws_iam_role.eventbridge_step_function_role.arn
}
