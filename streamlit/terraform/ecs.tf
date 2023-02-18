resource "aws_ecs_cluster" "main" {
  name = local.project_name
}

resource "aws_ecs_service" "main" {
  name                               = local.service_name
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = aws_ecs_task_definition.streamlit.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 60
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups  = [aws_security_group.streamlit.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.main.arn
    container_name   = local.service_name
    container_port   = local.container_port
  }

  # we ignore task_definition changes as the revision changes on deploy
  # of a new version of the application
  # desired_count is ignored as it can change due to autoscaling policy
  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

resource "aws_ecs_task_definition" "streamlit" {
  family                   = local.service_name
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  cpu                      = tostring(local.cpu)
  memory                   = tostring(local.memory)
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  container_definitions = jsonencode([
    {
      name      = local.service_name
      image     = "${aws_ecr_repository.aws-deploy.repository_url}:${local.service_name}"
      cpu       = local.cpu
      memory    = local.memory
      essential = true
      portMappings = [
        {
          containerPort = local.container_port
          hostPort      = local.container_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${local.service_name}-${local.environment}"
          awslogs-region        = local.region
          awslogs-stream-prefix = "${local.service_name}-${local.environment}"
        }
      }

    }
  ])
}

resource "aws_cloudwatch_log_group" "streamlit-lg" {
  name = "${local.service_name}-${local.environment}"
}

resource "aws_cloudwatch_log_stream" "streamlit-lg-stream" {
  log_group_name = "${local.service_name}-${local.environment}"
  name           = "${local.service_name}-${local.environment}"
  depends_on     = [aws_cloudwatch_log_group.streamlit-lg]
}
