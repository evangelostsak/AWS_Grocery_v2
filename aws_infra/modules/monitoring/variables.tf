variable "project_name" {
    description = "Project name used for naming resources"
	type = string
}

variable "environment" {
	description = "Environment name (dev/staging/prod)"
	type = string
}

variable "asg_name" {
	type = string
}

variable "alert_email" {
	type = string
}

variable "cpu_threshold" {
	type    = number
	default = 80
}

variable "cpu_period" {
	type    = number
	default = 300
}

variable "disk_threshold" {
	type    = number
	default = 80
}

variable "disk_period" {
	type    = number
	default = 300
}

variable "disk_filesystem" {
	type    = string
	default = "/dev/xvda1"
}

variable "disk_mount_path" {
	type    = string
	default = "/"
}

