variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The type of instance to use"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
	type = string
}

variable "security_group_id" {
	type = string
}

variable "subnet_ids" {
	type = list(string)
}

variable "target_group_arn" {
	type = string
}

variable "instance_profile_name" {
	type = string
}

variable "min_size" {
	type    = number
	default = 3
}

variable "max_size" {
	type    = number
	default = 3
}

variable "desired_capacity" {
	type    = number
	default = 3
}

variable "health_check_type" {
	type    = string
	default = "EC2"
}

variable "health_check_grace_period" {
	type    = number
	default = 300
}

variable "user_data" {
	type        = string
	default     = ""
	description = "If provided (already base64 if inline_user_data_base64=true) overrides default template"
}
variable "default_user_data_template_path" {
	type    = string
	default = "../templates/default_user_data.sh.tftpl"
}

variable "inline_user_data_base64" {
	type    = bool
	default = false
}

