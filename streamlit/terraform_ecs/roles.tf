resource "aws_iam_role" "service-role" {
  name               = "${local.project_name}-role"
  assume_role_policy = data.aws_iam_policy_document.aws-deploy-assume-role-policy.json
}

resource "aws_iam_role_policy" "service-role-policy" {
  policy = data.aws_iam_policy_document.service-policy.json
  role   = aws_iam_role.service-role.id
}

resource "aws_iam_role" "ecs-task-execution-role" {
  name               = "${local.project_name}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.aws-deploy-assume-role-policy.json
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs-task-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "service-policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "aws-deploy-assume-role-policy" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "ecs.amazonaws.com",
        "ecs-tasks.amazonaws.com",
      ]
    }
  }
}