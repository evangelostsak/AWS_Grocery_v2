variable "project_name" {
	description = "Project name used for naming EventBridge resources"
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
variable "rule_name" {
	description = "Name of the EventBridge rule"
	type        = string
}

variable "bucket_name" {
	description = "S3 bucket name monitored for object creation"
	type        = string
}

variable "db_dump_s3_key" {
	description = "Exact S3 key (object path) to trigger the workflow"
	type        = string
}

variable "state_machine_arn" {
	description = "ARN of the Step Functions state machine to invoke"
	type        = string
}

variable "eventbridge_role_arn" {
	description = "IAM role ARN allowing EventBridge to start executions"
	type        = string
}
