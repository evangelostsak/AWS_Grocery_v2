variable "project_name" {
  type    = string
  default = "grocery"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "common_tags" {
  type    = map(string)
  default = {}
}

variable "repository_name" {
  type = string
}