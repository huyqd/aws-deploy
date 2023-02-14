resource "aws_iam_role" "aws-deploy" {
  name               = local.project_name
  assume_role_policy = data.aws_iam_policy_document.aws-deploy-assume-policy.json
}

resource "aws_iam_role_policy" "aws-deploy-role-policy" {
  policy = data.aws_iam_policy_document.aws-deploy-policy.json
  role   = aws_iam_role.aws-deploy.id
}

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
resource "aws_iam_role" "aws-deploy-ecs-execution-role" {
  name               = "${local.project_name}-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.aws-deploy-assume-policy.json
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole" {
  role       = aws_iam_role.aws-deploy-ecs-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "aws-deploy-policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:Get*",
      "ecr:List*",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "aws-deploy-assume-policy" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

