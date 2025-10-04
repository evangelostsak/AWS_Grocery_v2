output "alb_sg_id" {
  description = "Security Group ID for the Application Load Balancer"
  value       = aws_security_group.alb.id
}

output "ec2_sg_id" {
  description = "Security Group ID for EC2/ASG instances"
  value       = aws_security_group.ec2.id
}

output "rds_sg_id" {
  description = "Security Group ID for RDS instances"
  value       = aws_security_group.rds.id
}

output "lambda_security_group_id" {
  value       = aws_security_group.lambda_sg.id
  description = "The ID of the Lambda security group"
}