# AWS ECR Module

This module provisions a single Elastic Container Registry (ECR) repository used to store both backend and frontend images with prefixed tags (e.g., `backend-<sha>`, `frontend-<sha>`).

## File Structure
```
modules/ecr/
├── locals.tf
├── main.tf
├── outputs.tf
├── variables.tf
├── versions.tf
├── README.md
```
- `main.tf`: ECR repository resource and policies.
- `locals.tf`: Naming and tagging logic.
- `variables.tf`: Input variables (project, environment, repository name, tags).
- `outputs.tf`: Exposes repository URL for build pipeline.

## Usage
```hcl
module "ecr" {
  source          = "../../modules/ecr"
  project_name    = var.project_name
  environment     = var.environment
  repository_name = var.ecr_repository_name
}
```

## Strategy
- A single repo lowers management overhead and allows consistent lifecycle policies.
- Distinguish images via tag prefixes instead of multiple repositories.

## Outputs
- `ecr_repository_url` – Full `<account>.dkr.ecr.<region>.amazonaws.com/<name>` used by CI and user data.

## Pipeline Integration
Build and push (example shell snippet in GitHub Actions step):
```bash
docker build -t "$ECR_REPO:backend-$IMAGE_TAG" backend/
docker build -t "$ECR_REPO:frontend-$IMAGE_TAG" frontend/
```

## Recommendations
- Add an ECR lifecycle policy to expire unreferenced older tags (e.g., keep last 30 of each prefix).
- Enable image scanning for vulnerability management.
