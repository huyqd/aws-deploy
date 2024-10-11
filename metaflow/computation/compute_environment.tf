module "ce_c5_instances" {
  source = "../compute_environment"

  batch_execution_role_arn           = aws_iam_role.batch_execution_role.arn
  compute_environment_name           = "metaflow-c5-instances"
  compute_environment_desired_vcpus  = 2
  compute_environment_instance_types = ["c5"]
  compute_environment_max_vcpus      = 36
  compute_environment_min_vcpus      = 0
  launch_template                    = [aws_launch_template.cpu]
  ecs_instance_role_arn              = aws_iam_instance_profile.ecs_instance_role.arn
  enable_fargate_on_batch            = false
  security_group_ids                 = concat([aws_security_group.this.id, ], var.compute_environment_additional_security_group_ids)
  standard_tags                      = var.standard_tags
  subnet_ids                         = var.subnet_ids
}

module "ce_g4dn_instances" {
  source = "../compute_environment"

  batch_execution_role_arn           = aws_iam_role.batch_execution_role.arn
  compute_environment_name           = "metaflow-g4dn-instances"
  compute_environment_desired_vcpus  = 4
  compute_environment_instance_types = ["g4dn"]
  compute_environment_max_vcpus      = 32
  compute_environment_min_vcpus      = 0
  launch_template                    = [aws_launch_template.cpu]
  ecs_instance_role_arn              = aws_iam_instance_profile.ecs_instance_role.arn
  enable_fargate_on_batch            = false
  security_group_ids                 = concat([aws_security_group.this.id, ], var.compute_environment_additional_security_group_ids)
  standard_tags                      = var.standard_tags
  subnet_ids                         = var.subnet_ids
}

module "ce_p3_instances" {
  source = "../compute_environment"

  batch_execution_role_arn           = aws_iam_role.batch_execution_role.arn
  compute_environment_name           = "metaflow-p3-instances"
  compute_environment_desired_vcpus  = 8
  compute_environment_instance_types = ["p3"]
  compute_environment_max_vcpus      = 32
  compute_environment_min_vcpus      = 0
  launch_template                    = [aws_launch_template.cpu]
  ecs_instance_role_arn              = aws_iam_instance_profile.ecs_instance_role.arn
  enable_fargate_on_batch            = false
  security_group_ids                 = concat([aws_security_group.this.id, ], var.compute_environment_additional_security_group_ids)
  standard_tags                      = var.standard_tags
  subnet_ids                         = var.subnet_ids
}

module "ce_r7g_instances" {
  source = "../compute_environment"

  batch_execution_role_arn           = aws_iam_role.batch_execution_role.arn
  compute_environment_name           = "metaflow-r7g-instances"
  compute_environment_desired_vcpus  = 2
  compute_environment_instance_types = ["r7g"]
  compute_environment_max_vcpus      = 64
  compute_environment_min_vcpus      = 0
  launch_template                    = [aws_launch_template.cpu]
  ecs_instance_role_arn              = aws_iam_instance_profile.ecs_instance_role.arn
  enable_fargate_on_batch            = false
  security_group_ids                 = concat([aws_security_group.this.id, ], var.compute_environment_additional_security_group_ids)
  standard_tags                      = var.standard_tags
  subnet_ids                         = var.subnet_ids
}

module "ce_g5g_instances" {
  source = "../compute_environment"

  batch_execution_role_arn           = aws_iam_role.batch_execution_role.arn
  compute_environment_name           = "metaflow-g5g-instances"
  compute_environment_desired_vcpus  = 4
  compute_environment_instance_types = ["g5g"]
  compute_environment_max_vcpus      = 32
  compute_environment_min_vcpus      = 0
  launch_template                    = [aws_launch_template.cpu]
  ecs_instance_role_arn              = aws_iam_instance_profile.ecs_instance_role.arn
  enable_fargate_on_batch            = false
  security_group_ids                 = concat([aws_security_group.this.id, ], var.compute_environment_additional_security_group_ids)
  standard_tags                      = var.standard_tags
  subnet_ids                         = var.subnet_ids
}

module "ce_fargate" {
  source = "../compute_environment"

  batch_execution_role_arn           = aws_iam_role.batch_execution_role.arn
  compute_environment_name           = "metaflow-fargate"
  compute_environment_desired_vcpus  = 2
  compute_environment_instance_types = [""]
  compute_environment_max_vcpus      = 64
  compute_environment_min_vcpus      = 0
  launch_template                    = []
  ecs_instance_role_arn              = aws_iam_instance_profile.ecs_instance_role.arn
  enable_fargate_on_batch            = true
  security_group_ids                 = concat([aws_security_group.this.id, ], var.compute_environment_additional_security_group_ids)
  standard_tags                      = var.standard_tags
  subnet_ids                         = var.subnet_ids
}
