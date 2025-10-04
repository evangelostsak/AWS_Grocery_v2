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

variable "s3_bucket_arn" {
	type = string
}

variable "iam_lambda_role_name" {
    type = string
}

variable "bucket_name" {
    type = string
}

variable "db_dump_s3_key" {
    type = string
}

variable "rds_arn" {
    type = string
}
