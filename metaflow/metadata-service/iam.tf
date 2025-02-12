data "aws_iam_policy_document" "metadata_svc_ecs_task_assume_role" {
  statement {
    effect = "Allow"

    principals {
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
      type = "Service"
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "metadata_svc_ecs_task_role" {
  name = "${var.resource_prefix}metadata-ecs-task${var.resource_suffix}"
  # Read more about ECS' `task_role` and `execution_role` here https://stackoverflow.com/a/49947471
  description        = "This role is passed to AWS ECS' task definition as the `task_role`. This allows the running of the Metaflow Metadata Service to have the proper permissions to speak to other AWS resources."
  assume_role_policy = data.aws_iam_policy_document.metadata_svc_ecs_task_assume_role.json

  tags = var.standard_tags
}

data "aws_iam_policy_document" "custom_s3_batch" {
  statement {
    sid = "ObjectAccessMetadataService"

    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      "${var.s3_bucket_arn}/*",
      "${var.s3_bucket_arn}"
    ]
  }
}

data "aws_iam_policy_document" "deny_presigned_batch" {
  statement {
    sid = "DenyPresignedBatch"

    effect = "Deny"

    actions = [
      "s3:*"
    ]

    resources = [
      "*"
    ]

    condition {
      test = "StringNotEquals"
      values = [
        "REST-HEADER"
      ]
      variable = "s3:authType"
    }
  }
}

resource "aws_iam_role_policy" "grant_custom_s3_batch" {
  name   = "custom_s3"
  role   = aws_iam_role.metadata_svc_ecs_task_role.name
  policy = data.aws_iam_policy_document.custom_s3_batch.json
}

resource "aws_iam_role_policy" "grant_deny_presigned_batch" {
  name   = "deny_presigned"
  role   = aws_iam_role.metadata_svc_ecs_task_role.name
  policy = data.aws_iam_policy_document.deny_presigned_batch.json
}
