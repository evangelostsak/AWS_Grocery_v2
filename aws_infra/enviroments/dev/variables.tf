# Environment-level Variables for dev

variable "region" {
	type    = string
	default = "eu-central-1"
}

variable "profile" {
	type    = string
}

variable "project_name" {
	type    = string
	default = "grocery"
}

variable "environment" {
	type    = string
	default = "dev"
}

variable "vpc_cidr" {
	type    = string
	default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
	type    = list(string)
	default = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
	type    = list(string)
	default = ["10.0.101.0/24","10.0.102.0/24","10.0.103.0/24"]
}

variable "availability_zones" {
	type    = list(string)
	default = ["eu-central-1a","eu-central-1b","eu-central-1c"]
}

variable "allowed_ssh_cidr" {
	type    = string
	default = "0.0.0.0/0"
}

variable "app_port" {
	type    = number
	default = 5000
}

variable "db_port" {
	type    = number
	default = 5432
}

variable "alb_health_check_path" {
	type    = string
	default = "/"
}

variable "alb_health_check_matcher" {
	type    = string
	default = "200"
}

variable "ami_id" {
	type    = string
	default = "ami-099b9a78992042e1f"
}

variable "instance_type" {
	type    = string
	default = "t3.micro"
}

variable "key_name" {
	type = string
}

variable "asg_min_size" {
	type    = number
	default = 3
}

variable "asg_max_size" {
	type    = number
	default = 3
}

variable "asg_desired_capacity" {
	type    = number
	default = 3
}

variable "asg_health_check_type" {
	type    = string
	default = "EC2"
}

variable "asg_health_check_grace_period" {
	type    = number
	default = 300
}

variable "db_name" {
	type    = string
}

variable "db_user" {
	type = string
}

variable "db_pass" {
	type = string
}

variable "db_class" {
	type    = string
	default = "db.t3.micro"
}

variable "read_replica_az" {
	type    = string
	default = "eu-central-1b"
}

variable "create_read_replica" {
	type    = bool
	default = true
}

variable "alert_email" {
	type = string
}

variable "cpu_alarm_threshold" {
	type    = number
	default = 80
}

variable "disk_alarm_threshold" {
	type    = number
	default = 80
}

variable "bucket_prefix" {
	type    = string
}

variable "db_dump_prefix" {
    description = "Prefix for database dump files in the S3 bucket"
    type        = string
}

variable "db_dump_filename" {
    description = "Database dump file name"
    type        = string
}

variable "layer_filename" {
    description = "Layer file name"
    type        = string
}

variable "layer_prefix" {
    description = "Prefix for Lambda layer files in the S3 bucket"
    type        = string
}