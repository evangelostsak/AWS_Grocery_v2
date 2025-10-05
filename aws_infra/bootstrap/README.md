# Terraform Bootstrap (Backend) Module

Bootstrap configuration creating remote backend artifacts: S3 state bucket + DynamoDB lock table, plus OIDC trust for GitHub Actions (if configured) before switching the root modules to use remote state.

## File Structure
```
bootstrap/
├── artifacts.tf
├── github.oidc.tf
├── locals.tf
├── outputs.tf
├── provider.tf
├── remote_backend.tf
├── variables.tf
├── versions.tf
├── README.md
```
- `artifacts.tf`: S3 bucket & DynamoDB lock table.
- `github.oidc.tf`: OIDC provider / IAM role for GitHub Actions (secure deployments).
- `remote_backend.tf`: (Optional) scaffolding for migrating to backend after bootstrap.
- `variables.tf`: Namespacing inputs & tagging.
- `outputs.tf`: Exposes `tf_state_bucket_name`, `tf_state_lock_table`.

## Usage (One-Time Init)
```hcl
module "bootstrap" {
  source       = "../bootstrap"
  project_name = var.project_name
  environment  = var.environment
}
```
Then configure your root backend:
```hcl
terraform {
  backend "s3" {
    bucket         = "<bucket>"
    key            = "envs/dev/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "<lock-table>"
    encrypt        = true
  }
}
```

## Outputs
- `tf_state_bucket_name`
- `tf_state_lock_table`

## Notes
- Wrapped by CI logic to skip creation if bucket/table already exist.
