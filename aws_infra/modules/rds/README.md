# AWS RDS Module

This module provisions a PostgreSQL RDS primary instance with optional read replica, basic monitoring integration, and sensible defaults for the grocery application.

## File Structure
```
modules/rds/
├── locals.tf
├── main.tf
├── outputs.tf
├── variables.tf
├── versions.tf
├── README.md
```
- `main.tf`: Primary DB, optional read replica, parameter/option settings.
- `locals.tf`: Naming and tagging helpers.
- `variables.tf`: Inputs (credentials, storage, engine options, replica toggle).
- `outputs.tf`: Connection endpoints and identifiers.
- `versions.tf`: Version constraints.

## Features
- PostgreSQL engine (default version 15.12).
- Optional Multi-AZ (enabled by default).
- Optional read replica (toggle via `create_read_replica`).
- Monitoring role ARN injection and Enhanced Monitoring interval.
- Snapshot skip (default) for faster destroy cycles in non-prod.

## Usage
```hcl
module "rds" {
  source                = "../../modules/rds"
  project_name          = var.project_name
  environment           = var.environment
  db_name               = var.db_name
  db_user               = var.db_user
  db_pass               = var.db_pass
  db_class              = var.db_class
  read_replica_az       = var.read_replica_az
  private_subnet_ids    = module.vpc.private_subnet_ids
  rds_security_group_id = module.security.rds_sg_id
  monitoring_role_arn   = module.iam.rds_monitoring_role_arn
  create_read_replica   = true
}
```

## Inputs (Highlights)
- `db_name`, `db_user`, `db_pass`, `db_class` – Core configuration.
- `private_subnet_ids` – Subnet group placement.
- `rds_security_group_id` – Restricted ingress from app / lambda.
- `multi_az` (bool, default true) – High availability toggle.
- `allocated_storage` (default 20) & `storage_type`.
- `create_read_replica` – Adds replica if true.
- `backup_retention_period` – 7 days default.
- `engine_version` – Bump consciously for upgrades.

## Outputs
- `db_endpoint` – Primary connection endpoint.
- `db_identifier` – Primary instance ID.
- `read_replica_endpoint` – Replica endpoint or null.

## Testing Suggestions
- `psql` connectivity test from a bastion / app instance.
- Verify replica (if enabled) shows `Select only` when connecting.

## Notes
- For production rotate credentials via Secrets Manager and reference via `db_pass` variable.
- Multi-AZ + replica will increase cost; tailor for dev/staging.
