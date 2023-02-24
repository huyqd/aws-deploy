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

resource "aws_iam_role" "sfn_role" {
  name               = "sfn-role"
  assume_role_policy = data.aws_iam_policy_document.sfn-assume-role.json
}

resource "aws_iam_role_policy" "sfn-policy" {
  policy = data.aws_iam_policy_document.sfn-policy.json
  role   = aws_iam_role.sfn_role.id
}

data "aws_iam_policy_document" "sfn-policy" {
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
      "SNS:Publish"
    ]
    resources = [
      aws_lambda_function.validateDragon.arn,
      aws_lambda_function.addDragon.arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "SNS:Publish"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "sfn-assume-role" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "states.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "gw-role" {
  name               = "gw-role"
  assume_role_policy = data.aws_iam_policy_document.gw-assume-role.json
}

resource "aws_iam_role_policy" "gw-policy" {
  policy = data.aws_iam_policy_document.gw-policy.json
  role   = aws_iam_role.gw-role.id
}

data "aws_iam_policy_document" "gw-policy" {
  statement {
    effect = "Allow"
    actions = [
      "states:StartExecution",
    ]
    resources = ["*"]
  }

}

data "aws_iam_policy_document" "gw-assume-role" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "apigateway.amazonaws.com",
      ]
    }
  }
}
