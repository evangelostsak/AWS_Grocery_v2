############################################
# SECURITY MODULE - Security Groups & Rules
############################################

# ALB security group
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "ALB security group"
  vpc_id      = var.vpc_id

  tags = merge(local.merged_tags, {
    Name = "${var.project_name}-${var.environment}-alb-sg"
  })
}

# ALB inbound HTTP
resource "aws_security_group_rule" "alb_http_in" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

# ALB egress to EC2 app port
resource "aws_security_group_rule" "alb_to_ec2" {
  type                     = "egress"
  from_port                = var.app_port
  to_port                  = var.app_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2.id
  security_group_id        = aws_security_group.alb.id
}

# EC2 security group
resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-${var.environment}-ec2-sg"
  description = "EC2/ASG security group"
  vpc_id      = var.vpc_id

  tags = merge(local.merged_tags, {
    Name = "${var.project_name}-${var.environment}-ec2-sg"
  })
}

# EC2 ingress from ALB
resource "aws_security_group_rule" "ec2_from_alb" {
  type                     = "ingress"
  from_port                = var.app_port
  to_port                  = var.app_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.ec2.id
}

# EC2 SSH
resource "aws_security_group_rule" "ec2_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.allowed_ssh_cidr]
  security_group_id = aws_security_group.ec2.id
}

# EC2 egress all
resource "aws_security_group_rule" "ec2_all_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2.id
}

resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "RDS security group"
  vpc_id      = var.vpc_id

  tags = merge(local.merged_tags, {
    Name = "${var.project_name}-${var.environment}-rds-sg"
  })
}

# RDS ingress from EC2
resource "aws_security_group_rule" "rds_from_ec2" {
  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2.id
  security_group_id        = aws_security_group.rds.id
}

# RDS ingress from Lambda
resource "aws_security_group_rule" "rds_from_lambda" {
  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lambda_sg.id
  security_group_id        = aws_security_group.rds.id
}


# Lambda security group
resource "aws_security_group" "lambda_sg" {
  name        = "${var.project_name}-${var.environment}-lambda-sg"
  description = "Allow Lambda to connect to RDS and S3"
  vpc_id      = var.vpc_id

  tags = merge(local.merged_tags, {
    Name = "${var.project_name}-${var.environment}-lambda-sg"
  })
}

# Lambda egress to RDS and S3
resource "aws_security_group_rule" "lambda_to_rds" {
  type                     = "egress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds.id
  security_group_id        = aws_security_group.lambda_sg.id
}