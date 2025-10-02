# Terraform Templates Directory

This folder contains reusable text templates rendered with Terraform's `templatefile()` function and embedded in the EC2 launch template user data (or future modules).

## File Naming Convention
- Use the extension `.tftpl` (Terraform Template) for all active templates.

## Current Files
| File | Status | Purpose |
|------|--------|---------|
| `default_user_data.sh.tftpl` | ACTIVE | Default EC2 user data executed on instance boot (installs Docker & CloudWatch Agent). |

## How Rendering Works
The EC2 module variable `default_user_data_template_path` points (by default) to `../templates/default_user_data.sh.tftpl`.
If the module input `user_data` is empty, the module renders this file; otherwise it uses the provided `user_data` string.

## Adding a New Template
1. Create `your_template_name.tftpl` here.
2. Expose a module variable for its path (or parameterize via variables passed into `templatefile`).
3. In the module using it, change logic:
   ```hcl
   locals {
     rendered = templatefile(var.my_template_path, {
       example_value = var.example_value
     })
   }
   ```
4. Pass any needed variables in the map.

## Parameterizing the User Data Template
To add dynamic values (e.g., log group, image tag), modify the template with interpolation placeholders:
```bash
LOG_GROUP_NAME="${log_group_name}"
IMAGE_TAG="${image_tag}"
```
Then update module code:
```hcl
locals {
  user_data_rendered = templatefile(var.default_user_data_template_path, {
    log_group_name = var.log_group_name
    image_tag      = var.image_tag
  })
}
```
Add `log_group_name` / `image_tag` as module variables.

## Best Practices
- Keep templates idempotent (reruns shouldn't break anything).
- Use `set -euo pipefail` in shell scripts for safer execution.
- Write critical actions to a marker file (e.g., `/var/log/user_data_complete`) for troubleshooting.
- Avoid hardcoding secrets; pull them from SSM Parameter Store or Secrets Manager at runtime if needed.

Maintainers: Update this README whenever you introduce or deprecate templates.
