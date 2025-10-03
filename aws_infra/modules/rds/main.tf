############################################
# RDS MODULE
############################################

resource "aws_db_subnet_group" "this" {
	name       = "${var.project_name}-${var.environment}-db-subnet-group"
	subnet_ids = var.private_subnet_ids
	tags = merge(local.merged_tags, {
		Name = "${var.project_name}-${var.environment}-db-subnets"
	})
}

resource "aws_db_instance" "primary" {
	allocated_storage       = var.allocated_storage
	storage_type            = var.storage_type
	engine                  = "postgres"
	engine_version          = var.engine_version
	instance_class          = var.db_class
	identifier              = var.db_name
	username                = var.db_user
	password                = var.db_pass
	skip_final_snapshot     = var.skip_final_snapshot
	multi_az                = var.multi_az
	backup_retention_period = var.backup_retention_period
	monitoring_interval     = var.monitoring_interval
	monitoring_role_arn     = var.monitoring_role_arn
	db_subnet_group_name    = aws_db_subnet_group.this.name
	publicly_accessible     = false
	vpc_security_group_ids  = [var.rds_security_group_id]
	tags = merge(local.merged_tags, {
		Name = "${var.project_name}-${var.environment}-db"
	})
}

resource "aws_db_instance" "read_replica" {
	count                   = var.create_read_replica ? 1 : 0
	identifier              = "${var.db_name}-replica"
	instance_class          = var.db_class
	engine                  = "postgres"
	replicate_source_db     = aws_db_instance.primary.identifier
	backup_retention_period = var.backup_retention_period
	skip_final_snapshot     = var.skip_final_snapshot
	publicly_accessible     = false
	monitoring_interval     = var.monitoring_interval
	monitoring_role_arn     = var.monitoring_role_arn
	availability_zone       = var.read_replica_az
	depends_on              = [aws_db_instance.primary]
	tags = merge(local.merged_tags, {
		Name = "${var.project_name}-${var.environment}-db-replica"
	})
}

