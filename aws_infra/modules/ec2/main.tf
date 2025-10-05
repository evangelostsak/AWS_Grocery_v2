############################################
# EC2 / ASG MODULE
############################################

locals {
  # Resolve template path (allow override, else derive relative to module root)
  default_user_data_template_absolute = var.default_user_data_template_path != "" ? var.default_user_data_template_path : "${path.module}/../../templates/default_user_data.sh.tftpl"

  # Render raw (unencoded) user data either from override or template
  user_data_raw = var.user_data != "" ? var.user_data : templatefile(local.default_user_data_template_absolute, {
    region             = data.region.current.name
    ecr_repository_url = var.ecr_repository_url
    image_tag          = var.image_tag
    ecr_domain         = split("/", var.ecr_repository_url)[0]
    alb_dns_name       = var.alb_dns_name
  })
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.project_name}-${var.environment}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile { name = var.instance_profile_name }

  monitoring { enabled = true }

  vpc_security_group_ids = [var.security_group_id]

  # Encode only if not already provided as base64 (controlled via inline_user_data_base64)
  user_data = var.inline_user_data_base64 ? local.user_data_raw : base64encode(local.user_data_raw)

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.merged_tags, {
      Name = "${var.project_name}-${var.environment}-instance"
    })
  }
}

resource "aws_autoscaling_group" "this" {
  name                      = "${var.project_name}-${var.environment}-asg"
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.subnet_ids
  target_group_arns         = [var.target_group_arn]
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = merge(local.merged_tags, {
      Name = "${var.project_name}-${var.environment}-instance"
    })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}