# AWS IAM Module

This module provisions IAM roles and policies for EC2, Lambda, Step Functions, EventBridge, and RDS monitoring integration used across the grocery stack.

## File Structure
```
modules/iam/
├── locals.tf
├── main.tf
├── outputs.tf
├── variables.tf
├── versions.tf
├── README.md
```
- `main.tf`: Role + policy attachments (EC2 instance profile, Lambda exec role, Step Functions role, EventBridge role, RDS monitoring role).
- `locals.tf`: Naming, tagging, JSON policy documents.
- `variables.tf`: Inputs (project, environment, referenced resource ARNs, S3 bucket, etc.).
- `outputs.tf`: Role ARNs / names exported for other modules.

## Usage
```hcl
module "iam" {
  source                      = "../../modules/iam"
  project_name                = var.project_name
  environment                 = var.environment
  s3_bucket_arn               = module.s3.bucket_arn
  bucket_name                 = module.s3.bucket_name
  db_dump_s3_key              = local.db_dump_s3_key
  rds_arn                     = module.rds.primary_arn
  lambda_function_arn         = module.lambda.lambda_function_arn
  state_machine_arn           = module.step_functions.state_machine_arn
  step_function_log_group_arn = module.monitoring.step_function_log_group_arn
  iam_lambda_role_name        = "${var.project_name}-${var.environment}-lambda-role"
}
```

## Outputs
- `instance_profile_name` – Attach to EC2 launch template.
- `ec2_role_arn` – For S3 access/logging permissions.
- `lambda_iam_role_arn` – Execution role for Lambda module.
- `sfn_role_arn` – Step Functions state machine role.
- `eventbridge_role_arn` – Event rule target invocation permissions.
- `rds_monitoring_role_arn` – Enhanced monitoring for RDS.

## Notes
- Principle of least privilege: tighten inline policies further as usage stabilizes.
- Consider migrating secrets access to AWS Secrets Manager with KMS encryption.
