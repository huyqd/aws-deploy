resource "aws_ecs_cluster" "aws-deploy" {
  name = local.project_name
}

resource "aws_ecs_service" "streamlit" {
  name            = local.service_name
  cluster         = aws_ecs_cluster.aws-deploy.id
  task_definition = aws_ecs_task_definition.streamlit.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.aws-deploy.arn
    container_name   = local.service_name
    container_port   = aws_lb_target_group.aws-deploy.port
  }

  lifecycle {
    ignore_changes = [desired_count, load_balancer]
  }

}

resource "aws_lb" "aws-deploy" {
  name               = local.project_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.aws-deploy.id]
  subnets            = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id]

  enable_deletion_protection = true

  tags = {
    Environment = local.environment
  }
}

resource "aws_lb_target_group" "aws-deploy" {
  name        = local.project_name
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.app_vpc.id
  target_type = "instance"

}

#resource "aws_lb_listener" "https" {
#  load_balancer_arn = aws_lb.aws-deploy.arn
#  port              = "443"
#  protocol          = "HTTPS"
#  ssl_policy        = "ELBSecurityPolicy-2016-08"
#  certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
#
#  default_action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.aws-deploy.arn
#  }
#}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.aws-deploy.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aws-deploy.arn
  }
}
