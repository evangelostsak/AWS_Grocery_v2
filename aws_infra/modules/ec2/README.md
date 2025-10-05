# AWS EC2 / ASG Module

This module provisions an Auto Scaling Group (ASG) and Launch Template for running the grocery application containers (frontend + backend) on Amazon Linux 2 instances. User data generates and runs a Docker Compose stack pulling images from a unified ECR repository.

## File Structure
```
modules/ec2/
├── locals.tf
├── main.tf
├── outputs.tf
├── variables.tf
├── versions.tf
├── README.md
```
- `main.tf`: Launch template, ASG definition, tag propagation.
- `locals.tf`: Tag merging / helper locals.
- `variables.tf`: All tunables (scaling sizes, health checks, user data controls, image parameters).
- `outputs.tf`: Exposes ASG name and launch template id.
- `versions.tf`: Version constraints.

## Key Features
- User data templating with automatic injection of `alb_dns_name`, image tag, repository URL.
- Single ECR repository strategy using prefixed tags: `backend-<tag>`, `frontend-<tag>`.
- Optional override for user data or template path.
- Propagated tags on instances via dynamic block.

## Usage
```hcl
module "ec2" {
  source                    = "../../modules/ec2"
  project_name              = var.project_name
  environment               = var.environment
  ami_id                    = var.ami_id
  instance_type             = var.instance_type
  key_name                  = var.key_name
  security_group_id         = module.security.ec2_sg_id
  subnet_ids                = module.vpc.public_subnet_ids
  target_group_arn          = module.alb.target_group_arn
  instance_profile_name     = module.iam.instance_profile_name
  min_size                  = 2
  max_size                  = 4
  desired_capacity          = 2
  health_check_type         = "EC2"
  health_check_grace_period = 300
  ecr_repository_url        = var.ecr_repository_url
  image_tag                 = var.image_tag  # e.g. set by pipeline IMAGE_TAG
  alb_dns_name              = module.alb.alb_dns_name
}
```

## Inputs (Highlights)
- `ami_id` – Amazon Linux 2 AMI.
- `instance_type` – e.g., t3.micro.
- `subnet_ids` – Public or private (if behind NAT + internal ALB).
- `ecr_repository_url` & `image_tag` – Container image location/version.
- `alb_dns_name` – Injected into frontend env var.
- Scaling: `min_size`, `max_size`, `desired_capacity`.
- Health: `health_check_type`, `health_check_grace_period`.
- User data overrides: `user_data`, `default_user_data_template_path`, `inline_user_data_base64`.

## Outputs
- `asg_name` – For alarms / scaling policies.
- `launch_template_id` – For debugging or drift detection.

## Example with Monitoring
```hcl
module "monitoring" {
  source       = "../../modules/monitoring"
  project_name = var.project_name
  environment  = var.environment
  asg_name     = module.ec2.asg_name
  # ... thresholds
}
```

## Testing Suggestions
- `terraform plan` after changing image_tag should show no infra changes (user data change may not rotate instances automatically—consider instance refresh policy).
- After apply, verify `/var/log/user-data.log` on an instance for successful compose startup.

## Notes
- Consider adding an ASG instance refresh policy tied to user data hash for automated rollout of new image tags.
- Ensure IAM instance profile allows ECR pull + CloudWatch logs/metrics.
