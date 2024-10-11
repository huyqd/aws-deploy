data "aws_iam_policy_document" "ecs_service_role_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    effect = "Allow"

    principals {
      identifiers = [
        "ec2.amazonaws.com",
        "ecs.amazonaws.com",
        "ecs-tasks.amazonaws.com",
      ]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "ecs_service_role" {
  name        = local.ecs_service_role_name
  # Learn more by reading this Terraform documentation https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/batch_compute_environment#argument-reference
  # Learn more by reading this AWS Batch documentation https://docs.aws.amazon.com/batch/latest/userguide/service_IAM_role.html
  description = "This role is passed to AWS ECS as a `service_role`. This allows AWS ECS to execute with proper permissions."

  assume_role_policy = data.aws_iam_policy_document.ecs_service_role_assume_role.json

  tags = var.standard_tags
}

data "aws_iam_policy_document" "custom_s3_list_batch" {
  statement {
    sid = "BucketAccessBatch"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]

    effect = "Allow"

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "custom_s3_batch" {
  statement {
    sid = "ObjectAccessBatch"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
    ]

    effect = "Allow"

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "custom_athena_batch" {
  statement {
    sid = "AthenaAccessBatch"
    actions = [
      "athena:StartQueryExecution",
      "athena:GetDataCatalog",
      "athena:GetQueryResults",
      "athena:GetQueryExecution",
      "athena:GetWorkGroup",
      "athena:ListDatabases",
      "athena:ListTableMetadata",
      "athena:ListQueryExecutions",
      "athena:StopQueryExecution",
      "glue:GetTable",
      "glue:GetDatabase",
      "glue:GetPartitions"
    ]
    effect = "Allow"

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "custom_log" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
    ]

    effect = "Allow"

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "grant_custom_s3_list_batch" {
  name   = "s3_list"
  role   = aws_iam_role.ecs_service_role.name
  policy = data.aws_iam_policy_document.custom_s3_list_batch.json
}

resource "aws_iam_role_policy" "grant_custom_s3_batch" {
  name   = "custom_s3"
  role   = aws_iam_role.ecs_service_role.name
  policy = data.aws_iam_policy_document.custom_s3_batch.json
}

resource "aws_iam_role_policy" "grant_custom_athena_batch" {
  name   = "custom_athena"
  role   = aws_iam_role.ecs_service_role.name
  policy = data.aws_iam_policy_document.custom_athena_batch.json
}

resource "aws_iam_role_policy" "grant_custom_log" {
  name   = "custom_log"
  role   = aws_iam_role.ecs_service_role.name
  policy = data.aws_iam_policy_document.custom_log.json
}
