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

variable "vpc_id" {
	type = string
}

variable "subnet_ids" {
	type = list(string)
}

variable "security_group_id" {
	type = string
}

variable "target_port" {
	type    = number
	default = 5000
}

variable "idle_timeout" {
	type    = number
	default = 60
}

variable "health_check_path" {
	type    = string
	default = "/"
}

variable "health_check_matcher" {
	type    = string
	default = "200"
}

variable "health_check_interval" {
	type    = number
	default = 15
}

variable "health_check_timeout" {
	type    = number
	default = 5
}

variable "health_check_healthy_threshold" {
	type    = number
	default = 2
}

variable "health_check_unhealthy_threshold" {
	type    = number
	default = 2
}

