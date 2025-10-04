variable "project_name" {
    description = "Project name used for naming resources"
	type = string
}

variable "environment" {
	description = "Environment name (dev/staging/prod)"
	type = string
}

variable "common_tags" {
    type = map(string)
    default = {}
}

variable "bucket_prefix" {
	type = string
}
variable "force_destroy" {
	type    = bool
	default = true
}

variable "versioning_enabled" {
	type    = bool
	default = true
}

variable "lifecycle_status" {
    description = "Lifecycle rule status (Enabled/Disabled)"
    type        = string
}

variable "expiration_days" {
    description = "Number of days after which objects expire"
    type        = number
}

variable "db_dump_prefix" {
    description = "Prefix for database dump files in the S3 bucket"
    type        = string
}

variable "avatar_prefix" {
    description = "Prefix for avatar files in the S3 bucket"
    type        = string
}

variable "avatar_filename" {
    description = "Avatar file name"
    type        = string
}

variable "avatar_path" {
    description = "Avatar file path"
    type        = string
}

variable "layer_filename" {
    description = "Layer file name"
    type        = string
}

variable "layer_path" {
    description = "Layer file path"
    type        = string
}

variable "layer_prefix" {
    description = "Prefix for Lambda layer files in the S3 bucket"
    type        = string
}

variable "ec2_iam_role_arn" {
    description = "ARN of the IAM role that EC2 instances will assume to access the S3 bucket"
    type        = string
}

variable "lambda_iam_role_arn" {
    description = "ARN of the IAM role that Lambda functions will assume to access the S3 bucket"
    type        = string
}
