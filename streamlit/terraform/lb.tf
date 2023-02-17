resource "aws_lb" "aws-deploy" {
  name               = local.project_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.aws-deploy.id]
  subnets            = local.public_subnets

  tags = {
    Environment = local.environment
  }
}

resource "aws_lb_target_group" "aws-deploy" {
  name        = local.project_name
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.app_vpc.id
  target_type = "ip"

  health_check {
    port = "traffic-port"
    path = "/_stcore/health"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.aws-deploy.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aws-deploy.arn
  }
}
