# AWS S3 Module

This module provisions a multi-purpose S3 bucket used for database dumps, avatar assets, and lambda layer storage for the grocery application.

## File Structure
```
modules/s3/
├── locals.tf
├── main.tf
├── outputs.tf
├── variables.tf
├── versions.tf
├── README.md
```
- `main.tf`: Bucket, versioning, lifecycle, object uploads.
- `locals.tf`: Naming patterns & computed keys.
- `variables.tf`: Inputs controlling prefixes, file names, lifecycle behavior.
- `outputs.tf`: Bucket name/ARN and computed S3 object keys.

## Usage
```hcl
module "s3" {
  source              = "../../modules/s3"
  project_name        = var.project_name
  environment         = var.environment
  lifecycle_status    = "Enabled"
  expiration_days     = 30
  bucket_prefix       = var.bucket_prefix
  db_dump_prefix      = var.db_dump_prefix
  avatar_prefix       = "avatars"
  avatar_filename     = "user_default.png"
  avatar_path         = "../../../backend/avatar/user_default.png"
  layer_prefix        = var.layer_prefix
  layer_filename      = var.layer_filename
  layer_path          = "../../layers/${var.layer_filename}"
  ec2_iam_role_arn    = module.iam.ec2_role_arn
  lambda_iam_role_arn = module.iam.lambda_iam_role_arn
}
```

## Inputs (Highlights)
- `bucket_prefix` – Base naming component.
- `db_dump_prefix` / `db_dump_filename` – Backup strategy.
- `avatar_prefix`, `avatar_filename`, `avatar_path` – App static assets.
- `layer_prefix`, `layer_filename`, `layer_path` – Lambda layer storage.
- `lifecycle_status`, `expiration_days` – Cost & retention tuning.

## Outputs
- `bucket_name`, `bucket_arn` – For downstream permissions.
- Object keys (dump, layers, avatars) for referencing from Lambda / Step Functions.

## Notes
- Consider separate buckets for isolation in production if access patterns differ.
- Enable encryption or enforce TLS only policy for stricter security posture.
