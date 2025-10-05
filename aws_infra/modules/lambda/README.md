# AWS Lambda Module

This module deploys a Lambda function plus (optional) layer used by Step Functions and EventBridge to assist with database dump orchestration.

## File Structure
```
modules/lambda/
├── locals.tf
├── main.tf
├── outputs.tf
├── variables.tf
├── versions.tf
├── README.md
```
- `main.tf`: Lambda function, layer attachment, environment variables.
- `locals.tf`: Naming, hash computations.
- `variables.tf`: Inputs (layer S3 key, zip path, role ARN, networking, DB connectivity env vars).
- `outputs.tf`: Function ARN (consumed by Step Functions & IAM policies).

## Usage
```hcl
module "lambda" {
  source                   = "../../modules/lambda"
  project_name             = var.project_name
  environment              = var.environment
  bucket_name              = module.s3.bucket_name
  lambda_layer_s3_key      = local.lambda_layer_s3_key
  lambda_zip_file          = "../../lambda_handler/lambda_function.zip"
  iam_lambda_role_arn      = module.iam.lambda_iam_role_arn
  private_subnet_ids       = module.vpc.private_subnet_ids
  lambda_security_group_id = module.security.ec2_sg_id
  rds_host                 = module.rds.primary_endpoint
  rds_port                 = var.db_port
  db_name                  = var.db_name
  db_username              = var.db_user
  rds_password             = var.db_pass
  db_dump_s3_key           = local.db_dump_s3_key
  region                   = var.region
}
```

## Outputs
- `lambda_function_arn` – For Step Functions & IAM.

## Notes
- Ensure role grants least privilege (S3 object get/put for dumps, RDS describe, CloudWatch logs).
- Keep deployment package small; leverage layer for large dependencies (e.g., psycopg2).
