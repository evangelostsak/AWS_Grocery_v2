# AWS ALB Module

This Terraform module provisions an Application Load Balancer (ALB), target group, and associated health check configuration for the grocery application stack.

## File Structure

```
modules/alb/
├── locals.tf
├── main.tf
├── outputs.tf
├── variables.tf
├── versions.tf
├── README.md
```

- `main.tf`: Declares ALB, target group, listener and necessary attachments.
- `locals.tf`: Houses derived names, tagging maps, and helper locals.
- `variables.tf`: All configurable inputs (ports, health check, subnet & SG wiring).
- `outputs.tf`: Key exported attributes (ALB ARN, DNS name, target group ARN).
- `versions.tf`: Required Terraform and provider version constraints.

## Usage

```hcl
module "alb" {
  source               = "../../modules/alb"
  project_name         = var.project_name
  environment          = var.environment
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.vpc.public_subnet_ids
  security_group_id    = module.security.alb_sg_id
  target_port          = 5000
  health_check_path    = "/health"
  health_check_matcher = "200"
}
```

## Inputs (Key)
- `vpc_id` (string) – VPC where ALB is created.
- `subnet_ids` (list(string)) – Typically public subnets for internet-facing ALB.
- `security_group_id` (string) – ALB security group.
- `target_port` (number, default 5000) – Backend target port.
- Health check tunables: `health_check_path`, `health_check_matcher`, interval/timeout & thresholds.

## Outputs
- `alb_arn` – ARN of ALB.
- `alb_dns_name` – Public DNS name (used by frontend build & user data).
- `target_group_arn` – Target group for ASG attachment.

## Example Integration
Used together with `ec2` module to attach the ASG instances:
```hcl
module "ec2" {
  # ...other args
  target_group_arn = module.alb.target_group_arn
}
```

## Testing Suggestions
- `terraform plan` should show only aws_lb*, aws_lb_target_group, aws_lb_listener resources.
- After apply: curl the `alb_dns_name` and expect 200 (once backend registered & healthy).

## Notes
- Idle timeout defaults to 60s; adjust for long‑poll / websockets if needed.
- Health check path and matcher should align with backend readiness endpoint.
