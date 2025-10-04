############################################
# Variables - Lambda Module
############################################

variable "project_name" {
  description = "Project name for tagging and naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev/staging/prod)"
  type        = string
}

variable "common_tags" {
  description = "Additional common tags to merge with enforced tags"
  type        = map(string)
  default     = {}
}

variable "bucket_name" {
  description = "S3 bucket containing lambda artifacts and SQL dump"
  type        = string
}

variable "lambda_layer_s3_key" {
  description = "S3 key for the lambda layer zip"
  type        = string
}

variable "lambda_zip_file" {
  description = "Local path to the lambda function deployment package zip"
  type        = string
}

variable "iam_lambda_role_arn" {
  description = "IAM role ARN assumed by the Lambda function"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for Lambda VPC config"
  type        = list(string)
}

variable "lambda_security_group_id" {
  description = "Security group ID attached to the Lambda function"
  type        = string
}

variable "rds_host" {
  description = "RDS endpoint hostname"
  type        = string
}

variable "rds_port" {
  description = "RDS port"
  type        = number
  default     = 5432
}

variable "db_name" {
  description = "Target database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "rds_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_dump_s3_key" {
  description = "S3 key of the database dump file"
  type        = string
}

variable "region" {
  description = "AWS region used for environment variables"
  type        = string
}

