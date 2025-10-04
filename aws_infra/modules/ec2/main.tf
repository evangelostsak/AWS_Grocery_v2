############################################
# EC2 / ASG MODULE
############################################

locals {
  user_data_rendered = var.user_data != "" ? var.user_data : base64encode(templatefile(var.default_user_data_template_path, {
    region             = data.region.current.name
    ecr_repository_url = var.ecr_repository_url
    image_tag          = var.image_tag
    ecr_domain         = split("/", var.ecr_repository_url)[0]
  }))
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.project_name}-${var.environment}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile { name = var.instance_profile_name }

  monitoring { enabled = true }

  vpc_security_group_ids = [var.security_group_id]

  user_data = var.inline_user_data_base64 ? local.user_data_rendered : base64encode(local.user_data_rendered)

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