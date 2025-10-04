variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "project_name" {
  description = "Project name used for naming resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/staging/prod)"
  type        = string
}

variable "common_tags"{
    description = "Common tags to apply to all resources"
    type        = map(string)
}

variable "restrict_by_tags" {
    description = "Whether to restrict access by tags"
    type        = bool
    default     = false
}
variable "github_org" {
  description = "GitHub organization or username for OIDC trust"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository for OIDC trust"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch allowed to assume the CI/CD role"
  type        = string
  default     = "development"
}