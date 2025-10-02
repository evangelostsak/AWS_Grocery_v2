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

