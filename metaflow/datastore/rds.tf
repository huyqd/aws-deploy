/*
 A subnet is attached to an availability zone so for db redundancy and
 performance we need to define additional subnet(s) and aws_db_subnet_group
 is how we define this.
*/
resource "aws_db_subnet_group" "this" {
  name       = local.pg_subnet_group_name
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name     = local.pg_subnet_group_name
      Metaflow = "true"
    }
  )
}

data "aws_vpc" "metaflow-vpc" {
  id = var.metaflow_vpc_id
}

/*
 Define a new firewall for our database instance.
*/
resource "aws_security_group" "rds_security_group" {
  name   = local.rds_security_group_name
  vpc_id = var.metaflow_vpc_id

  # ingress only from port 5432
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.metadata_service_security_group_id]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.metaflow-vpc.cidr_block]
  }

  # egress to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "random_password" "db_password" {
  length  = 64
  special = true
  # redefines the `special` variable by removing the `@`
  # this documentation https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Limits.html
  # shows that the `/`, `"`, `@` and ` ` cannot be used in the password
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_pet" "final_snapshot_id" {}

# Define rds db instance.
resource "aws_db_instance" "metaflow_datastore" {
  publicly_accessible      = false
  allocated_storage        = 20    # Allocate 20GB
  storage_type             = "gp2" # general purpose SSD
  storage_encrypted        = true
  engine                   = var.db_engine
  engine_lifecycle_support = "open-source-rds-extended-support-disabled"
  parameter_group_name     = "rds-parametergroup-pgsql16"
  engine_version           = var.db_engine_version
  instance_class           = var.db_instance_type # Hardware configuration
  identifier               = "${var.resource_prefix}-${var.db_name}-${var.resource_suffix}"
  # used for dns hostname needs to be customer unique in region
  db_name = var.db_name
  # unique id for CLI commands (name of DB table which is why we're not adding the prefix as no conflicts will occur and the API expects this table name)
  username              = var.db_username
  password              = random_password.db_password.result #random_password.this.result
  db_subnet_group_name  = aws_db_subnet_group.this.id
  max_allocated_storage = 1000
  # Upper limit of automatic scaled storage
  multi_az = true
  # Multiple availability zone?
  final_snapshot_identifier = "${var.resource_prefix}-${var.db_name}-final-snapshot-${var.resource_suffix}-${random_pet.final_snapshot_id.id}"
  # Snapshot upon delete
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]

  tags = merge(
    var.tags,
    {
      Name     = "${var.resource_prefix}${var.db_name}${var.resource_suffix}"
      Metaflow = "true"
    }
  )
}
