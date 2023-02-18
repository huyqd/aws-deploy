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
  load_balancer_arn = aws_lb.aws-deploy.arn
  port              = 80
  protocol          = "HTTP"

    default_action {
      type             = "forward"
      target_group_arn = aws_alb_target_group.aws-deploy.arn
    }
  }
#  default_action {
#    type = "redirect"
#
#    redirect {
#      port        = 443
#      protocol    = "HTTPS"
#      status_code = "HTTP_301"
#    }
#  }
#}

## Redirect traffic to target group
#resource "aws_alb_listener" "https" {
#  load_balancer_arn = aws_lb.aws-deploy.arn
#  port              = 443
#  protocol          = "HTTPS"
#
#  ssl_policy      = "ELBSecurityPolicy-2016-08"
#  certificate_arn = ""
#
#  # Select either cognito or oidc
#  # Cognito
#  default_action {
#    type = "authenticate-cognito"
#
#    authenticate_cognito {
#      user_pool_arn       = aws_cognito_user_pool.aws-deploy.arn
#      user_pool_client_id = aws_cognito_user_pool_client.aws-deploy.id
#      user_pool_domain    = aws_cognito_user_pool_domain.aws-deploy.domain
#    }
#  }
#
#  # OIDC
#  #  default_action {
#  #    type = "authenticate-oidc"
#  #
#  #    authenticate_oidc {
#  #      # Add these strings to Authorised redirect URIs:
#  #      # https://DNS/oauth2/idpresponse
#  #      # https://CNAME/oauth2/idpresponse
#  #      # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/listener-authenticate-users.html
#  #      authorization_endpoint = "https://accounts.google.com/o/oauth2/v2/auth"
#  #      client_id              = ""
#  #      client_secret          = ""
#  #      issuer                 = "https://accounts.google.com"
#  #      token_endpoint         = "https://www.googleapis.com/oauth2/v4/token"
#  #      user_info_endpoint     = "https://www.googleapis.com/oauth2/v3/userinfo"
#  #    }
#  #  }
#  #
#  default_action {
#    type             = "forward"
#    target_group_arn = aws_alb_target_group.aws-deploy.arn
#  }
#}