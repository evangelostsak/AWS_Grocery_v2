############################################
# ECR Module
############################################

resource "aws_ecr_repository" "this" {
  name = "${var.project_name}-${var.environment}-${var.repository_name}"
  tags = merge(local.merged_tags, {
    Name = "${var.project_name}-${var.environment}-${var.repository_name}"
  })

  image_tag_mutability = "MUTABLE"

  lifecycle {
    prevent_destroy = false
  }
}
