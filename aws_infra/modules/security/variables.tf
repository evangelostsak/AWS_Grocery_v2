variable "project_name" {
	type = string
}

variable "environment" {
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

