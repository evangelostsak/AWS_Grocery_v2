
# Grocery AWS Infrastructure & Deployment (Terraform + GitHub Actions)

> Modernized, modular AWS deployment for a dual‑service (backend + frontend) application using a single ECR repository, immutable image tags, and fully automated provisioning.

## 1. Overview

This repository contains the Infrastructure as Code (Terraform) and deployment automation for the Masterschool grocery application. The application itself (Flask backend + React frontend) lives under `backend/` and `frontend/`; the AWS infrastructure is under `aws_infra/` and is organized into composable modules.

Key characteristics:
- Modular Terraform (VPC, Security, ALB, EC2/ASG, RDS, S3, IAM, Lambda, Step Functions, EventBridge, Monitoring, ECR, Remote Backend Bootstrap)
- Split CI/CD workflows: validation (CI) and deployment (CD) with OIDC to AWS
- Single ECR repository using tag prefixes (`backend-<IMAGE_TAG>`, `frontend-<IMAGE_TAG>`) + `latest` aliases
- ASG user data generates a Docker Compose file on instance boot (idempotent start)
- Conditional bootstrap of remote backend (S3 + DynamoDB) only if not already present
- Automatic injection of ALB DNS into frontend build runtime via user data env var
- RDS primary + optional read replica for read offloading & resiliency
- Event-driven dump orchestration (S3 -> EventBridge -> Step Functions -> Lambda)
- Observability via CloudWatch Alarms + custom metrics (disk + memory via agent)

For application-level docs see `app.md`.

---

## 2. Diagram Placeholders


### 2.1 High-Level Architecture
<!-- DIAGRAM: High-Level Architecture (VPC, ALB, ASG/EC2, RDS primary+replica, S3, ECR, EventBridge, Step Functions, Lambda, IAM, CloudWatch) -->

### 2.2 Module Dependency Graph
<!-- DIAGRAM: Terraform Module Dependency Graph (vpc -> security -> alb/ec2/rds -> monitoring/iam -> lambda -> step_functions -> event_bridge) -->

### 2.3 CI/CD Pipeline Flow
<!-- DIAGRAM: GitHub Actions (push) -> CI (fmt/validate/plan) -> artifact -> workflow_run -> CD (bootstrap? -> build/push images -> terraform apply Phase 1 -> terraform apply Phase 2) -->

### 2.4 Runtime Container Layout
<!-- DIAGRAM: EC2 instance: docker compose (frontend container :80 served by nginx; backend container :5000), network SGs, health checks -->

### 2.5 Data / Backup Flow
<!-- DIAGRAM: RDS -> dump -> S3 (db-dumps/) -> EventBridge Rule -> Step Functions -> Lambda restore -->

### 2.6 User Data Sequence
<!-- DIAGRAM: Launch -> Install -> ECR Login -> Pull images -> Generate compose -> Up -> Verify -->

### 2.7 Security Context
<!-- DIAGRAM: IAM Roles (EC2, Lambda, Step Functions, EventBridge, RDS Monitoring) + GitHub OIDC trust relationship -->

### 2.8 Monitoring & Alerting
<!-- DIAGRAM: Metrics -> Alarms -> SNS / Email -->

---

## 3. Technologies & Services

| Layer | Component | Purpose |
|-------|-----------|---------|
| Compute | EC2 (ASG) | Runs backend & frontend via Docker Compose |
| Network | VPC, Subnets, SGs, ALB | Segmentation, ingress, load balancing |
| Data | RDS (PostgreSQL) + Read Replica | Primary + read scalability |
| Storage | S3 | Avatars, DB dumps, Lambda layer zip |
| Orchestration | Step Functions | DB restoration / workflow engine |
| Events | EventBridge | Triggers state machine on dump upload |
| Serverless | Lambda | DB dump restore / auxiliary tasks |
| Registry | ECR (single repo) | Stores both images (prefixed tags) |
| IAM | Roles & Instance Profile | Least-privilege access control |
| Monitoring | CloudWatch Alarms + Agent | CPU, disk, memory (agent) |
| CI/CD | GitHub Actions (CI + CD) | Plan, build, deploy, tag images |

---

## 4. Repository Layout

```
.
├── README.md
├── app.md                        # Application 
├── docker-compose.yml            # Local/dev compose (not used in EC2 user data)
├── aws_infra/                    # Terraform infrastructure root
│   ├── grocery.png               # Architecture diagram (placeholder)
│   ├── bootstrap/                # Remote backend + GitHub OIDC bootstrap
│   ├── enviroments/              # Environment compositions (dev, etc.)
│   │   └── dev/                  # dev environment root module wiring
│   ├── modules/                  # Reusable Terraform modules
│   │   ├── alb/
│   │   ├── ec2/
│   │   ├── ecr/
│   │   ├── event_bridge/
│   │   ├── iam/
│   │   ├── lambda/
│   │   ├── monitoring/
│   │   ├── rds/
│   │   ├── remote_backend/
│   │   ├── s3/
│   │   ├── security/
│   │   ├── step_functions/
│   │   └── vpc/
│   ├── lambda_handler/           # Packaged lambda_function.zip source location
│   ├── layers/                   # Pre-built Lambda layer zips
│   └── templates/                # User data & other templatefile() assets
├── backend/                      # Flask backend application source
├── frontend/                     # React frontend (multi-stage Docker → nginx)
└── .github/workflows/            # CI (ci.yaml) & CD (cd.yaml) workflows
```

---

## 5. Terraform Modules (Summary)

| Module | Key Outputs | Notes |
|--------|-------------|-------|
| vpc | vpc_id, public/private_subnet_ids | Foundation for networking |
| security | alb_sg_id, ec2_sg_id, rds_sg_id | Segregated SGs per tier |
| alb | alb_dns_name, target_group_arn | Health checks configurable |
| ec2 | asg_name, launch_template_id | User data drives dual container startup |
| rds | db_endpoint, read_replica_endpoint | Optional replica & Multi-AZ toggle |
| s3 | bucket_name, object keys | Avatars, dumps, lambda layer storage |
| ecr | ecr_repository_url | Single repo strategy |
| iam | role ARNs, instance_profile_name | Centralized IAM management |
| lambda | lambda_function_arn | Layer support for psycopg2 etc. |
| step_functions | state_machine_arn | Orchestration of DB workflows |
| event_bridge | (rule specifics) | Triggers step functions on S3 events |
| monitoring | step_function_log_group_arn | Alarms for CPU/disk + logs |
| remote_backend | state bucket + lock table | Created once via bootstrap |

---

## 6. CI/CD Workflows

### 6.1 CI (`ci.yaml`)
Non-mutating validation:
- terraform fmt / init / validate / plan
- Uploads plan artifact
- Concurrency to prevent overlapping runs

### 6.2 CD (`cd.yaml`)
Triggered on successful CI (workflow_run):
1. Conditional backend bootstrap (skips if bucket/table exist)
2. Image build & push (backend & frontend) with immutable `backend-<sha>`, `frontend-<sha>` and `-latest` tags
3. Export `IMAGE_TAG` as `TF_VAR_image_tag`
4. Terraform Phase 1 (foundational targets: vpc, security, s3, iam, alb, monitoring, ecr, etc.)
5. Terraform Phase 2 (full apply including ec2, rds, lambda, step_functions, event_bridge)
6. Cleanup (remove sensitive artifacts)

Security:
- GitHub OIDC → AWS IAM role (no long‑lived keys)
- Secrets masked; `.env` not printed

---

## 7. Image & Deployment Strategy

| Aspect | Approach |
|--------|----------|
| Repository | Single ECR repo (simpler policies) |
| Differentiation | Tag prefixes: `backend-<IMAGE_TAG>`, `frontend-<IMAGE_TAG>` |
| Mutability | Immutable SHA tags + rolling `backend-latest`, `frontend-latest` |
| Runtime | ASG user data pulls images & writes `docker-compose.yml` |
| Frontend API URL | Injected via compose env `REACT_APP_BACKEND_SERVER=http://${alb_dns_name}` |

### User Data Lifecycle
1. Install Docker & CloudWatch Agent (Amazon Linux 2)
2. ECR login with retry loop
3. Pull images by prefix
4. Generate compose file + backend env file
5. Start stack if not already running (idempotent)
6. Verify containers (`backend`, `frontend`) are up

---

## 8. Environment Variables / tfvars

See `aws_infra/enviroments/dev/dev.tfvars.example` for a fully annotated example.

Key values injected at deploy time:
- `ami_id` (updated periodically)
- `image_tag` (set by pipeline; default `latest` for manual tests)
- `db_pass` (override via `TF_VAR_db_pass` / secret store)

Example snippet:
```hcl
project_name = "grocery"
environment  = "dev"
region       = "eu-central-1"
ami_id       = "ami-xxxxxxxx"
ecr_repository_name = "grocery-app"
ecr_repository_url  = "123456789012.dkr.ecr.eu-central-1.amazonaws.com/grocery-app"
image_tag    = "latest"
```

---

## 9. Deployment (Local / Manual)

```bash
cd aws_infra/enviroments/dev
terraform init           # After remote backend is bootstrapped
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

Check user data execution on an instance:
```bash
ssh -i <key>.pem ec2-user@<public-ip>
sudo tail -f /var/log/user-data.log
docker ps
```

Access application:
```
http://<alb_dns_name>
```

Destroy (dev only):
```bash
terraform destroy -var-file=dev.tfvars
```

---

## 10. Operational Procedures

| Task | Action |
|------|--------|
| Release new version | Merge → CI → CD builds images | 
| Hotfix backend only | Change backend code → pipeline still builds both (frontend cached) |
| Rotate DB password | Update secret source → re-run apply (instances unaffected) |
| Scale capacity | Edit `asg_desired_capacity` / `asg_max_size` → apply |
| Roll new base AMI | Update `ami_id` + (optionally) add ASG instance refresh |
| Recover from failed container | ASG replacement or manual `docker compose up -d` |

---

## 11. Monitoring & Observability

Current:
- CPU & Disk alarms (per ASG instances)
- CloudWatch Agent for memory & disk usage
- Step Functions log group

---

## 12. Backup & Restore Flow
1. Database dump uploaded to S3 (`db-dumps/…`).
2. EventBridge rule matches object key pattern.
3. Step Functions state machine triggered.
4. Lambda orchestrates restore / validation tasks.

See Diagram in section 2.5 to visualize.

---

## 13. Security & Hardening
| Area | Control |
|------|---------|
| Auth to AWS | GitHub OIDC (no static creds) |
| Instance Access | SSH (restrict CIDR) → migrate to SSM Session Manager later |
| Secrets | Avoid `.env` in repo; use variables + pipeline injection |
| Network | SGs least privilege (ALB → EC2, EC2 → RDS) |
| Images | Immutable tags; potential to add vulnerability scan (Trivy/ECR scan) |
| State | Remote backend (S3 + DynamoDB lock) |
| Logging | User data log, CloudWatch agent metrics |

---

## 14. Contributing
1. Create feature branch off `development`
2. Run `terraform fmt` + ensure `ci.yaml` passes locally if possible
3. Open PR → CI must be green before merge to trigger CD (on protected branches)

---

## 15. Cleanup / Teardown
For ephemeral environments:
```bash
terraform destroy -var-file=dev.tfvars
```
Ensure ECR images & S3 objects pruned if cost sensitivity is high.

---

## 16. Appendix
| Item | Path / Reference |
|------|------------------|
| User data log | `/var/log/user-data.log` |
| Compose directory | `/opt/grocery/` on instances |
| Terraform plan artifact | GitHub Actions CI artifacts |
| Frontend build arg | `REACT_APP_BACKEND_SERVER` (in Docker build) |

---

© 2025 Grocery Infrastructure Project. MIT Licence



