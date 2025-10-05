# AWS Remote Backend Module

Creates S3 bucket and DynamoDB table used for Terraform remote state storage and state locking (when bootstrapping new environments).

## File Structure
```
modules/remote_backend/
├── locals.tf
├── main.tf
├── outputs.tf
├── variables.tf
├── versions.tf
├── README.md
```
- `main.tf`: Bucket, DynamoDB table, encryption & versioning setup.
- `variables.tf`: Inputs controlling names, tags, retention.
- `outputs.tf`: State bucket & lock table names.

## Usage
```hcl
module "remote_backend" {
  source       = "../../modules/remote_backend"
  project_name = var.project_name
  environment  = var.environment
}
```

## Outputs
- `state_bucket_name`
- `lock_table_name`

## Notes
- Applied only once during bootstrap workflow; subsequent applies should skip if detected.
