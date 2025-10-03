variable "project_name" {
    description = "Project name used for naming resources"
	type = string
}

variable "environment" {
	description = "Environment name (dev/staging/prod)"
	type = string
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

