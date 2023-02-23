resource "aws_iam_role" "read-lambda" {
  assume_role_policy = data.aws_iam_policy_document.assume-role.json
  name               = "ReadLambda"
}

resource "aws_iam_role" "read-write-lambda" {
  assume_role_policy = data.aws_iam_policy_document.assume-role.json
  name               = "ReadWriteLambda"
}

resource "aws_iam_role_policy" "read" {
  policy = data.aws_iam_policy_document.read.json
  role   = aws_iam_role.read-lambda.id
}

resource "aws_iam_role_policy" "read-write" {
  policy = data.aws_iam_policy_document.read-write.json
  role   = aws_iam_role.read-write-lambda.id
}


data "aws_iam_policy_document" "assume-role" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "read" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
      "ssm:GetParameter"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "read-write" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
      "ssm:GetParameter"
    ]
    resources = ["*"]
  }
}

