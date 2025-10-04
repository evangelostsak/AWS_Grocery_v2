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
  aws_region           = var.region
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
  source              = "../../modules/s3"
  project_name        = var.project_name
  environment         = var.environment
  lifecycle_status    = var.lifecycle_status
  expiration_days     = var.expiration_days
  bucket_prefix       = var.bucket_prefix
  db_dump_prefix      = var.db_dump_prefix
  avatar_prefix       = "avatars"
  avatar_filename     = "user_default.png"
  avatar_path         = "../../backend/avatar/user_default.png"
  layer_prefix        = var.layer_prefix
  layer_filename      = var.layer_filename
  layer_path          = "../../layers/${var.layer_filename}"
  ec2_iam_role_arn    = module.iam.ec2_role_arn
  lambda_iam_role_arn = module.iam.lambda_iam_role_arn
}

# --- Lambda ---
module "lambda" {
  source                 = "../../modules/lambda"
  project_name           = var.project_name
  environment            = var.environment
  bucket_name            = module.s3.bucket_name
  lambda_layer_s3_key    = local.lambda_layer_s3_key
  lambda_zip_file        = "../../lambda_handler/lambda_function.zip"
  iam_lambda_role_arn    = module.iam.lambda_iam_role_arn
  private_subnet_ids     = module.vpc.private_subnet_ids
  lambda_security_group_id = module.security.ec2_sg_id
  rds_host               = module.rds.primary_endpoint
  rds_port               = var.db_port
  db_name                = var.db_name
  db_username            = var.db_user
  rds_password           = var.db_pass
  db_dump_s3_key         = local.db_dump_s3_key
  region                 = var.region
}

# --- IAM ---
module "iam" {
  source              = "../../modules/iam"
  project_name        = var.project_name
  environment         = var.environment
  s3_bucket_arn       = module.s3.bucket_arn
  bucket_name         = module.s3.bucket_name
  db_dump_s3_key      = local.db_dump_s3_key
  rds_arn             = module.rds.primary_arn
  lambda_function_arn = module.lambda.lambda_function_arn
  state_machine_arn   = module.step_functions.state_machine_arn
  step_function_log_group_arn = module.monitoring.step_function_log_group_arn
  iam_lambda_role_name = "${var.project_name}-${var.environment}-lambda-role"
}

# --- ALB ---
module "alb" {
  source              = "../../modules/alb"
  project_name        = var.project_name
  environment         = var.environment
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
  project_name           = var.project_name
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
  ecr_repository_url     = var.ecr_repository_url
  image_tag              = var.image_tag
}

# --- RDS ---
module "rds" {
  source                 = "../../modules/rds"
  project_name           = var.project_name
  environment            = var.environment
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
  environment   = var.environment
  project_name  = var.project_name
  asg_name      = module.ec2.asg_name
  alert_email   = var.alert_email
  cpu_threshold = var.cpu_alarm_threshold
  disk_threshold = var.disk_alarm_threshold
}

# --- Step Functions ---
module "step_functions" {
  source                     = "../../modules/step_functions"
  project_name               = var.project_name
  environment                = var.environment
  state_machine_name         = "${var.project_name}-${var.environment}-db-restore-step-function"
  sfn_role_arn               = module.iam.sfn_role_arn
  step_function_log_group_arn = module.monitoring.step_function_log_group_arn
  db_identifier              = var.db_name
  bucket_name                = module.s3.bucket_name
  db_dump_s3_key             = local.db_dump_s3_key
  lambda_function_arn        = module.lambda.lambda_function_arn
}

# --- Event Bridge ---
module "event_bridge" {
  source               = "../../modules/event_bridge"
  project_name         = var.project_name
  environment          = var.environment
  rule_name            = "${var.project_name}-${var.environment}-s3-dump-uploaded"
  bucket_name          = module.s3.bucket_name
  db_dump_s3_key       = local.db_dump_s3_key
  state_machine_arn    = module.step_functions.state_machine_arn
  eventbridge_role_arn = module.iam.eventbridge_role_arn
}
