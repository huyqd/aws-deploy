resource "aws_lb" "aws-deploy" {
  name               = "${local.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public.*.id

  enable_deletion_protection = false
}

resource "aws_alb_target_group" "aws-deploy" {
  name        = "${local.project_name}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200-299"
    timeout             = "3"
    path                = local.healthcheck_path
    unhealthy_threshold = "2"
  }

  depends_on = [aws_lb.aws-deploy]
}

# Redirect to https listener
resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.aws-deploy.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.aws-deploy.arn

    #    redirect {
    #      port        = 443
    #      protocol    = "HTTPS"
    #      status_code = "HTTP_301"
    #    }
  }
}

## Redirect traffic to target group
#resource "aws_alb_listener" "https" {
#  load_balancer_arn = aws_lb.main.id
#  port              = 443
#  protocol          = "HTTPS"
#
#  ssl_policy      = "ELBSecurityPolicy-2016-08"
#  certificate_arn = local.tsl_certificate_arn
#
#  default_action {
#    target_group_arn = aws_alb_target_group.main.arn
#    type             = "forward"
#  }
#}