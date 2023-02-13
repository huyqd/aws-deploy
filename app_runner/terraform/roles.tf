resource "aws_iam_role" "aws-deploy" {
  name               = local.project_name
  assume_role_policy = data.aws_iam_policy_document.aws-deploy-assume-policy.json
}

resource "aws_iam_role_policy" "aws-deploy-role-policy" {
  policy = data.aws_iam_policy_document.aws-deploy-policy.json
  role   = aws_iam_role.aws-deploy.id
}

data "aws_iam_policy_document" "aws-deploy-policy" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ecr:Get*",
      "ecr:List*",
    ]
  }
}

data "aws_iam_policy_document" "aws-deploy-assume-policy" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apprunner.amazonaws.com"]
    }
  }
}

