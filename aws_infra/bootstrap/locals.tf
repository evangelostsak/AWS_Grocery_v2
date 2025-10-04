locals {
  enforced_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "bootstrap"
  }

  merged_tags = merge(var.common_tags, local.enforced_tags)
}