############################################
# OUTPUTS (Surfaced for environment)
############################################

output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "db_endpoint" {
  description = "Primary RDS database endpoint"
  value       = module.rds.db_endpoint
}

output "s3_bucket_name" {
  description = "S3 bucket name for application data"
  value       = module.s3.bucket_name
}