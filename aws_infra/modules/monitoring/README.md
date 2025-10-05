# AWS Monitoring Module

Provides CloudWatch monitoring primitives for the stack: alarms and log groups (including Step Functions log group) plus optional metrics thresholds.

## File Structure
```
modules/monitoring/
├── locals.tf
├── main.tf
├── outputs.tf
├── variables.tf
├── versions.tf
├── README.md
```
- `main.tf`: Alarms (CPU, disk), log group for Step Functions, SNS topics/subscriptions (if implemented).
- `variables.tf`: Thresholds & emails.
- `outputs.tf`: Exposes log group ARN(s) used by IAM & Step Functions.

## Usage
```hcl
module "monitoring" {
  source        = "../../modules/monitoring"
  project_name  = var.project_name
  environment   = var.environment
  asg_name      = module.ec2.asg_name
  alert_email   = var.alert_email
  cpu_threshold = 70
  disk_threshold = 80
}
```

## Outputs
- `step_function_log_group_arn` – For IAM policies.

## Notes
- Extend with additional alarms (Memory via CloudWatch Agent metrics, 5xx ALB errors, RDS CPU) as requirements grow.
