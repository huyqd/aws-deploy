module "metaflow-datastore" {
  source = "./datastore"

  bucket_name                        = "${var.resource_prefix}-datastore-${var.resource_suffix}"
  db_name                            = "metaflow"
  db_username                        = "metaflow"
  db_instance_type                   = "db.t4g.small"
  db_engine                          = "postgres"
  db_engine_version                  = "16"
  force_destroy_s3_bucket            = false
  metadata_service_security_group_id = module.metaflow-metadata-service.metadata_service_security_group_id
  metaflow_vpc_id                    = var.vpc_id
  resource_prefix                    = var.resource_prefix
  resource_suffix                    = var.resource_suffix
  subnet_ids                         = var.subnet_ids
  tags                               = var.tags
}

module "metaflow-metadata-service" {
  source = "./metadata-service"

  resource_prefix = "${var.resource_prefix}-"
  resource_suffix = "-${var.resource_suffix}"

  access_list_cidr_blocks          = var.access_list_cidr_blocks
  database_name                    = module.metaflow-datastore.database_name
  database_password                = module.metaflow-datastore.database_password
  database_username                = module.metaflow-datastore.database_username
  db_migrate_lambda_zip_file       = null
  enable_api_basic_auth            = true
  enable_api_gateway               = true
  fargate_execution_role_arn       = module.metaflow-computation.ecs_execution_role_arn
  metadata_service_container_image = local.metadata_service_container_image
  metaflow_vpc_id                  = var.vpc_id
  rds_master_instance_endpoint     = module.metaflow-datastore.rds_master_instance_endpoint
  s3_bucket_arn                    = module.metaflow-datastore.s3_bucket_arn
  subnet_ids                       = var.subnet_ids
  lb_subnet_ids                    = var.lb_subnet_ids
  ecs_pub_subnet_ids               = var.ecs_pub_subnet_ids
  vpc_cidr_blocks                  = var.vpc_cidr_blocks
  with_public_ip                   = var.with_public_ip

  standard_tags = var.tags
}

module "metaflow-computation" {
  source = "./computation"

  metaflow_vpc_id = var.vpc_id
  resource_prefix = local.resource_prefix
  resource_suffix = local.resource_suffix
  standard_tags   = var.tags
  subnet_ids      = var.subnet_ids
}

module "metaflow-sfn" {
  source = "./step-functions"

  batch_job_queue_arns = module.metaflow-computation.batch_job_queue_arns
  resource_prefix      = local.resource_prefix
  resource_suffix      = local.resource_suffix
  s3_bucket_arn        = module.metaflow-datastore.s3_bucket_arn
  standard_tags        = var.tags
  active               = true
}

# have this script to deploy
# module "metaflow" {
#   source = "../tf_modules/modules_for_metaflow"
#
#   resource_prefix    = local.resource_prefix
#   resource_suffix    = local.resource_suffix
#   subnet_ids         = concat(module.vpc.private_subnets, module.vpc.public_subnets)
#   tags               = local.tags
#   vpc_cidr_blocks    = [module.vpc.vpc_cidr_block]
#   vpc_id             = module.vpc.vpc_id
#   ecs_pub_subnet_ids = module.vpc.public_subnets
#   lb_subnet_ids      = module.vpc.public_subnets
#   with_public_ip     = true
# }
