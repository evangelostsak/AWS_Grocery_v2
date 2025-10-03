variable "project_name" {
    description = "Project name used for naming resources"
	type = string
}

variable "environment" {
	description = "Environment name (dev/staging/prod)"
	type = string
}

variable "vpc_id" {
	type = string
}

variable "allowed_ssh_cidr" {
	type = string
}

variable "app_port" {
	type    = number
	default = 5000
}

variable "db_port" {
	type    = number
	default = 5432
}

