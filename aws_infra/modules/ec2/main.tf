############################################
# EC2 / ASG MODULE
############################################

locals {
  user_data_rendered = var.user_data != "" ? var.user_data : base64encode(templatefile(var.default_user_data_template_path, {}))
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.name_prefix}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile { name = var.instance_profile_name }

  monitoring { enabled = true }

  vpc_security_group_ids = [var.security_group_id]

  user_data = var.inline_user_data_base64 ? local.user_data_rendered : base64encode(local.user_data_rendered)

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.name_prefix}-instance"
      Environment = var.environment
    }
  }
}

resource "aws_autoscaling_group" "app_asg" {
  name                      = "grocery-asg"
  min_size                  = 3
  max_size                  = 3
  desired_capacity          = 3
  vpc_zone_identifier       = [aws_subnet.public_a.id, aws_subnet.public_b.id, aws_subnet.public_c.id]
  target_group_arns         = [aws_lb_target_group.instances.arn]
  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.app_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "grocery-instance"
    propagate_at_launch = true
  }
}