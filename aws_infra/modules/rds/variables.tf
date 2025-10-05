variable "project_name" {
  description = "Project name used for naming resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/staging/prod)"
  type        = string
}

variable "common_tags" {
  type    = map(string)
  default = {}
}

variable "db_name" {
  type = string
}

variable "db_user" {
  type = string
}

variable "db_pass" {
  type = string
}

variable "db_class" {
  type = string
}

variable "read_replica_az" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "rds_security_group_id" {
  type = string
}

variable "db_subnet_group_name" {
  description = "The name of the DB Subnet Group"
  type        = string
}
variable "monitoring_role_arn" {
  type = string
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "storage_type" {
  type    = string
  default = "standard"
}

variable "engine_version" {
  type    = string
  default = "15.12"
}

variable "skip_final_snapshot" {
  type    = bool
  default = true
}

variable "multi_az" {
  type    = bool
  default = true
}

variable "backup_retention_period" {
  type    = number
  default = 7
}

variable "monitoring_interval" {
  type    = number
  default = 60
}

variable "create_read_replica" {
  type    = bool
  default = true
}

