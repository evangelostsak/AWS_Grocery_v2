variable "name_prefix" {
	description = "Prefix for naming VPC related resources"
	type        = string
}

variable "environment" {
	description = "Environment name (dev/staging/prod)"
	type        = string
}

variable "vpc_cidr" {
	description = "CIDR block for the VPC"
	type        = string
}

variable "public_subnet_cidrs" {
	description = "List of CIDR blocks for public subnets"
	type        = list(string)
}

variable "private_subnet_cidrs" {
	description = "List of CIDR blocks for private subnets"
	type        = list(string)
}

variable "availability_zones" {
	description = "List of availability zones aligned with subnet cidr indexes"
	type        = list(string)
}

