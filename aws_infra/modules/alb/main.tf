############################################
# ALB MODULE
############################################

resource "aws_lb" "this" {
	name               = "${var.name_prefix}-alb"
	load_balancer_type = "application"
	subnets            = var.subnet_ids
	security_groups    = [var.security_group_id]
	idle_timeout       = var.idle_timeout
	tags = {
		Name = "${var.name_prefix}-alb"
	}
}

resource "aws_lb_target_group" "this" {
	name     = "${var.name_prefix}-tg"
	port     = var.target_port
	protocol = "HTTP"
	vpc_id   = var.vpc_id
	health_check {
		path                = var.health_check_path
		protocol            = "HTTP"
		matcher             = var.health_check_matcher
		interval            = var.health_check_interval
		timeout             = var.health_check_timeout
		healthy_threshold   = var.health_check_healthy_threshold
		unhealthy_threshold = var.health_check_unhealthy_threshold
	}
	tags = {
		Name = "${var.name_prefix}-tg"
	}
}

resource "aws_lb_listener" "http" {
	load_balancer_arn = aws_lb.this.arn
	port              = 80
	protocol          = "HTTP"
	default_action {
		type             = "forward"
		target_group_arn = aws_lb_target_group.this.arn
	}
}

