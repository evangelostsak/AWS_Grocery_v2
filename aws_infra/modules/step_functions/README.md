# AWS Step Functions Module

Provisions a state machine orchestrating database dump restoration or related workflows, integrating with Lambda and S3.

## File Structure
```
modules/step_functions/
├── locals.tf
├── main.tf
├── outputs.tf
├── variables.tf
├── versions.tf
├── README.md
```
- `main.tf`: State machine definition & role attachment.
- `variables.tf`: Inputs (project, env, state machine name, ARNs, S3 dump key, lambda function ARN, DB identifier).
- `outputs.tf`: State machine ARN.

## Usage
```hcl
module "step_functions" {
  source              = "../../modules/step_functions"
  project_name        = var.project_name
  environment         = var.environment
  state_machine_name  = "${var.project_name}-${var.environment}-db-restore-step-function"
  sfn_role_arn        = module.iam.sfn_role_arn
  db_identifier       = var.db_name
  bucket_name         = module.s3.bucket_name
  db_dump_s3_key      = local.db_dump_s3_key
  lambda_function_arn = module.lambda.lambda_function_arn
  step_function_log_group_arn = module.monitoring.step_function_log_group_arn
}
```

## Outputs
- `state_machine_arn` – For IAM & EventBridge.

## Notes
- Keep definition JSON modular; consider externalizing large ASL documents.
- Use CloudWatch Logs for debugging execution failures.
