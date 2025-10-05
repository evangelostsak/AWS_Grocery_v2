# AWS VPC Module

Foundational networking module creating a VPC with public and private subnets used by the rest of the stack.

## File Structure
```
modules/vpc/
├── locals.tf
├── main.tf
├── outputs.tf
├── variables.tf
├── versions.tf
├── README.md
```
- `main.tf`: VPC, subnets, IGW/NAT (if present), route tables & associations.
- `locals.tf`: Naming, IP math, tagging.
- `variables.tf`: CIDR blocks, AZ distribution, DNS flags.
- `outputs.tf`: VPC ID, subnet IDs.

## Usage
```hcl
module "vpc" {
  source               = "../../modules/vpc"
  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  aws_region           = var.region
}
```

## Outputs
- `vpc_id`, `public_subnet_ids`, `private_subnet_ids`.

## Notes
- Ensure subnet CIDRs do not overlap with existing peered networks.
