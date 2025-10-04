variable "project_name" {
  description = "Project name used for naming resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/staging/prod)"
  type        = string
}

variable "common_tags" {
  description = "Additional user-supplied tags merged with enforced tags"
  type        = map(string)
  default     = {}
}

variable "s3_bucket_arn" {
  description = "ARN of the primary application S3 bucket"
  type        = string
}

variable "iam_lambda_role_name" {
  description = "Name to assign to the Lambda IAM role"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket used for application artifacts"
  type        = string
}

variable "db_dump_s3_key" {
  description = "S3 object key of the database dump file"
  type        = string
}

variable "rds_arn" {
  description = "ARN of the primary RDS instance"
  type        = string
}

variable "lambda_function_arn" {
  description = "ARN of the Lambda function invoked by Step Functions"
  type        = string
}

variable "state_machine_arn" {
  description = "ARN of the Step Functions state machine started by EventBridge"
  type        = string
}

variable "step_function_log_group_arn" {
  description = "CloudWatch Log Group ARN used for Step Functions execution logging"
  type        = string
}
