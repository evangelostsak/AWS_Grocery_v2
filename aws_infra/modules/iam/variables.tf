variable "project_name" {
    description = "Project name used for naming resources"
	type = string
}

variable "environment" {
	description = "Environment name (dev/staging/prod)"
	type = string
}

variable "s3_bucket_arn" {
	type = string
}

