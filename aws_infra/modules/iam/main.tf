############################################
# IAM MODULE - Roles, Policies, Instance Profile
############################################

resource "aws_iam_role" "ec2_role" {
	name = "${var.project_name}-${var.environment}-ec2-role"
	assume_role_policy = jsonencode({
		Version = "2012-10-17"
		Statement = [{
			Effect = "Allow"
			Principal = { Service = "ec2.amazonaws.com" }
			Action = "sts:AssumeRole"
		}]
	})
	tags = merge(local.merged_tags, {
		Name = "${var.project_name}-${var.environment}-ec2-role"
	})
}

resource "aws_iam_policy" "s3_access" {
	name        = "${var.project_name}-${var.environment}-s3-access"
	description = "Allow EC2 instances to access application S3 bucket"
	policy = jsonencode({
		Version = "2012-10-17",
		Statement = [
			{
				Effect = "Allow",
				Action = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"],
				Resource = [
					var.s3_bucket_arn,
					"${var.s3_bucket_arn}/*"
				]
			}
		]
	})
	tags = merge(local.merged_tags, {
		Name = "${var.project_name}-${var.environment}-s3-access"
	})
}

resource "aws_iam_role_policy_attachment" "attach_s3" {
	role       = aws_iam_role.ec2_role.name
	policy_arn = aws_iam_policy.s3_access.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
	name = "${var.project_name}-${var.environment}-ec2-instance-profile"
	role = aws_iam_role.ec2_role.name
}

# RDS Enhanced Monitoring Role
resource "aws_iam_role" "rds_monitoring" {
	name = "${var.project_name}-${var.environment}-rds-monitoring-role"
	assume_role_policy = jsonencode({
		Version = "2012-10-17"
		Statement = [{
			Effect = "Allow"
			Principal = { Service = "monitoring.rds.amazonaws.com" }
			Action = "sts:AssumeRole"
		}]
	})
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_policy" {
	role       = aws_iam_role.rds_monitoring.name
	policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

