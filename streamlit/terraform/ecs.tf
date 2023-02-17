resource "aws_ecs_cluster" "aws-deploy" {
  name = local.project_name
}

resource "aws_ecs_service" "streamlit" {
  name            = local.service_name
  cluster         = aws_ecs_cluster.aws-deploy.id
  task_definition = aws_ecs_task_definition.streamlit.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.aws-deploy.arn
    container_name   = local.service_name
    container_port   = 8501
  }

  network_configuration {
    subnets          = local.public_subnets
    assign_public_ip = true
    #    security_groups = [aws_security_group.service-sg.id]
  }

}


resource "aws_cloudwatch_log_group" "streamlit-lg" {
  name = "${local.service_name}-${local.environment}"
}

resource "aws_cloudwatch_log_stream" "streamlit-lg-stream" {
  log_group_name = "${local.service_name}-${local.environment}"
  name           = "${local.service_name}-${local.environment}"
}
