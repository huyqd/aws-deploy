resource "aws_ecs_cluster" "aws-deploy" {
  name = local.project_name
}

resource "aws_ecs_service" "streamlit" {
  name            = local.service_name
  cluster         = aws_ecs_cluster.aws-deploy.id
  task_definition = aws_ecs_task_definition.streamlit.arn
  desired_count   = 1
  iam_role        = aws_iam_role.aws-deploy.arn

  load_balancer {
    target_group_arn = aws_lb_target_group.aws-deploy.arn
    container_name   = local.service_name
    container_port   = aws_lb_target_group.aws-deploy.port
  }

  lifecycle {
    ignore_changes = [desired_count, load_balancer]
  }

}

resource "aws_lb_target_group" "aws-deploy" {
  name     = local.project_name
  port     = 8051
  protocol = "HTTP"
  vpc_id   = aws_vpc.app_vpc.id
}