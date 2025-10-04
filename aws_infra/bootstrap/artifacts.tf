# Generate backend.tf
resource "local_file" "backend_config" {
  filename = "${path.module}/../../environments/${var.environment}/backend.tf"
  content  = <<EOT
terraform {
  backend "s3" {
    bucket         = "${module.remote_backend.tf_state_bucket_name}"
    dynamodb_table = "${module.remote_backend.tf_state_lock_table}"
    key            = "terraform.tfstate"
    region         = "${var.aws_region}"
  }
}
EOT
}

# Generate bootstrap_outputs.json
resource "local_file" "bootstrap_outputs" {
  filename = "${path.module}/../../environments/${var.environment}/artifacts/bootstrap_outputs.json"
  content = jsonencode({
    project_name            = var.project_name
    environment             = var.environment
    aws_region              = var.aws_region
    tf_state_bucket_name    = module.remote_backend.tf_state_bucket_name
    tf_state_lock_table     = module.remote_backend.tf_state_lock_table
    github_actions_role_arn = aws_iam_role.github_actions.arn
  })
}