# GitHub Actions Role for Terraform CI/CD
resource "aws_iam_role" "github_actions" {
  name = "${var.project_name}-${var.environment}-terraform-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/${var.github_branch}"
          }
        }
      }
    ]
  })

  # Attach the permission boundary
  permissions_boundary = aws_iam_policy.github_actions_boundary.arn

  tags = merge(
    { Name = "${var.project_name}-${var.environment}-terraform-github-actions-role" },
    local.merged_tags
  )
}

# Optional IAM policy restriction by tags
locals {
  tag_conditions = var.restrict_by_tags ? {
    "StringEquals" = {
      "aws:RequestTag/Project"     = var.project_name
      "aws:RequestTag/Environment" = var.environment
    }
  } : {}
}

# Create a managed policy for GitHub Actions role (broad for agility in dev)
resource "aws_iam_policy" "github_actions_policy" {
  name        = "${var.project_name}-${var.environment}-terraform-github-actions-policy"
  description = "Permissions for GitHub Actions to execute Terraform commands"
  path        = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "*"
        Resource  = "*"
        Condition = local.tag_conditions
      }
    ]
  })
  tags = merge(
    { Name = "${var.project_name}-${var.environment}-terraform-github-actions-policy" },
    local.merged_tags
  )
}

# Attach the managed policy to the role
resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}

# Permission boundary to prevent privilege escalation
resource "aws_iam_policy" "github_actions_boundary" {
  name        = "${var.project_name}-${var.environment}-github-actions-boundary"
  description = "Permission boundary to prevent IAM user/key creation and direct user policy management"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Action = [
          "iam:CreateUser",
          "iam:DeleteUser",
          "iam:AttachUserPolicy",
          "iam:PutUserPolicy",
          "iam:CreateAccessKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(
    { Name = "${var.project_name}-${var.environment}-github-actions-boundary" },
    local.merged_tags
  )
}