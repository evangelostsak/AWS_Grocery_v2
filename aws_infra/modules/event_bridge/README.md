# AWS EventBridge Module

Defines an EventBridge rule that triggers a Step Functions state machine when a database dump object is created in S3.

## File Structure
```
modules/event_bridge/
├── locals.tf
├── main.tf
├── outputs.tf
├── variables.tf
├── versions.tf
├── README.md
```
- `main.tf`: Rule + target, permissions for invocation.
- `variables.tf`: Inputs (bucket name, dump key, state machine ARN, role ARN).
- `outputs.tf`: (If any) export rule name / ARN (extend as needed).

## Usage
```hcl
module "event_bridge" {
  source               = "../../modules/event_bridge"
  project_name         = var.project_name
  environment          = var.environment
  rule_name            = "${var.project_name}-${var.environment}-s3-dump-uploaded"
  bucket_name          = module.s3.bucket_name
  db_dump_s3_key       = local.db_dump_s3_key
  state_machine_arn    = module.step_functions.state_machine_arn
  eventbridge_role_arn = module.iam.eventbridge_role_arn
}
```

## Notes
- Pattern matches object key for db dumps; adjust for broader event ingestion.
- Extend with dead-letter or retry policies if processing becomes complex.
