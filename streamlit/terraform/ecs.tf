resource "aws_ecs_cluster" "aws-deploy" {
  name = local.project_name
}

resource "aws_ecs_service" "aws-deploy" {
  name                               = local.project_name
  cluster                            = aws_ecs_cluster.aws-deploy.id
  task_definition                    = aws_ecs_task_definition.aws-deploy.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 60
  launch_type                        = local.launch_type
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups  = [aws_security_group.service.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.aws-deploy.arn
    container_name   = local.project_name
    container_port   = local.container_port
  }

  # we ignore task_definition changes as the revision changes on deploy
  # of a new version of the application
  # desired_count is ignored as it can change due to autoscaling policy
  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

resource "aws_ecs_task_definition" "aws-deploy" {
  family                   = local.project_name
  execution_role_arn       = aws_iam_role.ecs-task-execution-role.arn
  task_role_arn            = aws_iam_role.service-role.arn
  cpu                      = tostring(local.cpu)
  memory                   = tostring(local.memory)
  requires_compatibilities = [local.launch_type]
  network_mode             = "awsvpc"

  container_definitions = jsonencode([
    {
      name      = local.project_name
      image     = "${aws_ecr_repository.aws-deploy.repository_url}:${local.project_name}"
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
          awslogs-group         = "${local.project_name}-${local.environment}"
          awslogs-region        = local.region
          awslogs-stream-prefix = "${local.project_name}-${local.environment}"
        }
      }

    }
  ])
}

resource "aws_cloudwatch_log_group" "aws-deploy" {
  name = "${local.project_name}-${local.environment}"
}

resource "aws_cloudwatch_log_stream" "aws-deploy" {
  log_group_name = "${local.project_name}-${local.environment}"
  name           = "${local.project_name}-${local.environment}"
  depends_on     = [aws_cloudwatch_log_group.aws-deploy]
}
