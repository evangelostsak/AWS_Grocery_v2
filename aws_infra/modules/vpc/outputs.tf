output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [for s in aws_subnet.private : s.id]
}

output "availability_zones" {
  description = "List of AZs used by this VPC layout"
  value       = var.availability_zones
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.this.name
  description = "The name of DB Subnet Group"
}
