variable "project_name" {
	description = "Project name for naming the state machine"
	type        = string
}

variable "environment" {
	description = "Deployment environment (dev/staging/prod)"
	type        = string
}

variable "common_tags" {
	type    = map(string)
	default = {}
}

variable "state_machine_name" {
	description = "Name of the Step Functions state machine"
	type        = string
}

variable "sfn_role_arn" {
	description = "IAM role ARN assumed by Step Functions"
	type        = string
}
variable "db_identifier" {
	description = "RDS instance identifier to poll for availability"
	type        = string
}

variable "bucket_name" {
	description = "S3 bucket name containing the database dump"
	type        = string
}

variable "db_dump_s3_key" {
	description = "S3 object key of the database dump file"
	type        = string
}

variable "lambda_function_arn" {
	description = "ARN of the Lambda function to invoke once conditions are met"
	type        = string
}

variable "wait_seconds" {
	description = "Seconds to wait between S3 file existence checks"
	type        = number
	default     = 60
}

variable "step_function_log_group_arn" {
	description = "CloudWatch Log Group ARN for state machine execution logging"
	type        = string
}
