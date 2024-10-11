resource "aws_batch_job_queue" "ec2_amd" {
  name     = "metaflow-ec2-amd"
  state    = "ENABLED"
  priority = 1

  compute_environment_order {
    order               = 1
    compute_environment = module.ce_c5_instances.compute_environment_arn
  }

  compute_environment_order {
    order               = 2
    compute_environment = module.ce_g4dn_instances.compute_environment_arn
  }

  compute_environment_order {
    order               = 3
    compute_environment = module.ce_p3_instances.compute_environment_arn
  }

  tags = var.standard_tags
}

resource "aws_batch_job_queue" "ec2_arm" {
  name     = "metaflow-ec2-arm"
  state    = "ENABLED"
  priority = 1

  compute_environment_order {
    order               = 1
    compute_environment = module.ce_r7g_instances.compute_environment_arn
  }

  compute_environment_order {
    order               = 2
    compute_environment = module.ce_g5g_instances.compute_environment_arn
  }

  tags = var.standard_tags
}

resource "aws_batch_job_queue" "fargate" {
  name     = "metaflow-fargate"
  state    = "ENABLED"
  priority = 1

  compute_environment_order {
    order               = 1
    compute_environment = module.ce_fargate.compute_environment_arn
  }

  tags = var.standard_tags
}
