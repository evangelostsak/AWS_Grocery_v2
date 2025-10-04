############################################
# DEV ENVIRONMENT COMPOSITION
############################################

provider "aws" {
  region  = var.region
  profile = var.profile
}

# --- VPC ---
module "vpc" {
  source               = "../../modules/vpc"
  project_name         = var.project_name  
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

# --- Security ---
module "security" {
  source               = "../../modules/security"
  project_name         = var.project_name
  environment          = var.environment
  vpc_id               = module.vpc.vpc_id
  allowed_ssh_cidr     = var.allowed_ssh_cidr
  app_port             = var.app_port
  db_port              = var.db_port
}

# --- S3 ---
module "s3" {
  source        = "../../modules/s3"
  bucket_prefix = "${local.name_prefix}-data"
}

# --- IAM ---
module "iam" {
  source        = "../../modules/iam"
  name_prefix   = local.name_prefix
  s3_bucket_arn = module.s3.bucket_arn
}

# --- ALB ---
module "alb" {
  source              = "../../modules/alb"
  name_prefix         = local.name_prefix
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.public_subnet_ids
  security_group_id   = module.security.alb_sg_id
  target_port         = var.app_port
  health_check_path   = var.alb_health_check_path
  health_check_matcher = var.alb_health_check_matcher
}

# --- EC2 / ASG ---
module "ec2" {
  source                 = "../../modules/ec2"
  name_prefix            = local.name_prefix
  environment            = var.environment
  ami_id                 = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  security_group_id      = module.security.ec2_sg_id
  subnet_ids             = module.vpc.public_subnet_ids
  target_group_arn       = module.alb.target_group_arn
  instance_profile_name  = module.iam.instance_profile_name
  min_size               = var.asg_min_size
  max_size               = var.asg_max_size
  desired_capacity       = var.asg_desired_capacity
  health_check_type      = var.asg_health_check_type
  health_check_grace_period = var.asg_health_check_grace_period
}

# --- RDS ---
module "rds" {
  source                 = "../../modules/rds"
  name_prefix            = local.name_prefix
  db_name                = var.db_name
  db_user                = var.db_user
  db_pass                = var.db_pass
  db_class               = var.db_class
  read_replica_az        = var.read_replica_az
  private_subnet_ids     = module.vpc.private_subnet_ids
  rds_security_group_id  = module.security.rds_sg_id
  monitoring_role_arn    = module.iam.rds_monitoring_role_arn
  create_read_replica    = var.create_read_replica
}

# --- Monitoring ---
module "monitoring" {
  source        = "../../modules/monitoring"
  name_prefix   = local.name_prefix
  asg_name      = module.ec2.asg_name
  alert_email   = var.alert_email
  cpu_threshold = var.cpu_alarm_threshold
  disk_threshold = var.disk_alarm_threshold
}
