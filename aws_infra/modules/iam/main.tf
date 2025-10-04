############################################
# IAM MODULE - EC2 to S3 ECR Roles, Policies, Instance Profile
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

# Attach S3 Access Policy
resource "aws_iam_role_policy_attachment" "attach_s3" {
	role       = aws_iam_role.ec2_role.name
	policy_arn = aws_iam_policy.s3_access.arn
}

# Attach AmazonEC2ContainerRegistryPullOnly Policy
resource "aws_iam_role_policy_attachment" "ecr_pull" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

resource "aws_iam_instance_profile" "ec2_profile" {
	name = "${var.project_name}-${var.environment}-ec2-instance-profile"
	role = aws_iam_role.ec2_role.name
	tags = merge(local.merged_tags, {
		Name = "${var.project_name}-${var.environment}-ec2-instance-profile"
	})
}

############################################
# IAM MODULE - RDS Monitoring Role + Policy
############################################

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
	tags = merge(local.merged_tags, {
		Name = "${var.project_name}-${var.environment}-rds-monitoring-role"
	})
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_policy" {
	role       = aws_iam_role.rds_monitoring.name
	policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

############################################
# IAM MODULE - Lambda Role + Policies
############################################

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = var.iam_lambda_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Policy: Lambda can read SQLite dump from S3
resource "aws_iam_policy" "lambda_s3_policy" {
  name        = "${var.project_name}-${var.environment}-lambda-s3-access-policy"
  description = "Allow Lambda to read the SQLite dump from S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::${var.bucket_name}"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "arn:aws:s3:::${var.bucket_name}/${var.db_dump_s3_key}"
      }
    ]
  })
}

# Policy: Allow Lambda to describe RDS instances
resource "aws_iam_policy" "lambda_rds_policy" {
  name        = "${var.project_name}-${var.environment}-lambda-rds-access-policy"
  description = "Allow Lambda to describe RDS instances"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds:DescribeDBInstances",
          "rds:Connect"
        ]
        Resource = var.rds_arn
      }
    ]
  })
}

# Policy: Allow Lambda to manage network interfaces (needed for VPC access)
resource "aws_iam_policy" "lambda_vpc_policy" {
  name        = "${var.project_name}-${var.environment}-lambda-vpc-access-policy"
  description = "Allow Lambda to manage network interfaces in VPC"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:AttachNetworkInterface"
        ]
        Resource = "*"
      }
    ]
  })
}

# Policy: Allow Lambda to write logs
resource "aws_iam_policy" "lambda_logging_policy" {
  name        = "${var.project_name}-${var.environment}-lambda-logging-policy"
  description = "Allow Lambda to write logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}
# Attach policies to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_s3_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_rds_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_rds_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_vpc_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_logging_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_logging_policy.arn
}