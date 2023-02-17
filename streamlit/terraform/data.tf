data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_ecs_task_definition" "streamlit" {
  family                   = local.service_name
  execution_role_arn       = aws_iam_role.aws-deploy-ecs-execution-role.arn
  task_role_arn            = aws_iam_role.aws-deploy.arn
  cpu                      = "256"
  memory                   = "1024"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  container_definitions = jsonencode([
    {
      name      = local.service_name
      image     = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/${aws_ecr_repository.aws-deploy.name}:${local.service_name}"
      cpu       = 256
      memory    = 1024
      essential = true
      portMappings = [
        {
          containerPort = 8501
          hostPort      = 8501
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
