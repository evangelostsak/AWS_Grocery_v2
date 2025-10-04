locals {
  enforced_tags = {
    Project     = var.project_name
    Environment = var.environment
    Terraform   = "true"
    ManagedBy   = "terraform"
  }
  merged_tags = merge(local.enforced_tags, var.common_tags)
}
