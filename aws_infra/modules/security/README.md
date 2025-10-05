# AWS Security Module

Creates security groups for ALB, EC2 instances, RDS, and potentially Lambda ENIs; encapsulates ingress/egress rules for the application tiers.

## File Structure
```
modules/security/
├── locals.tf
├── main.tf
├── outputs.tf
├── variables.tf
├── versions.tf
├── README.md
```
- `main.tf`: Security group resources and rules.
- `variables.tf`: Ports, CIDRs, environment context.
- `outputs.tf`: Exposes SG IDs consumed by ALB, EC2, RDS, Lambda.

## Usage
```hcl
module "security" {
  source           = "../../modules/security"
  project_name     = var.project_name
  environment      = var.environment
  vpc_id           = module.vpc.vpc_id
  allowed_ssh_cidr = var.allowed_ssh_cidr
  app_port         = var.app_port
  db_port          = var.db_port
}
```

## Outputs
- `alb_sg_id`, `ec2_sg_id`, `rds_sg_id` – Attach to respective resources.

## Notes
- Lock down SSH to corporate CIDRs; prefer SSM Session Manager.
- Add egress restrictions if data exfiltration concerns arise.
