module "remote_backend" {
  source       = "../../modules/remote_backend"
  project_name = var.project_name
  environment  = var.environment
  common_tags  = var.common_tags
}