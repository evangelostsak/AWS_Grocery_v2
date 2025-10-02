output "db_endpoint" {
	description = "Primary RDS instance endpoint address"
	value       = aws_db_instance.primary.address
}

output "db_identifier" {
	description = "Primary RDS instance identifier"
	value       = aws_db_instance.primary.id
}

output "read_replica_endpoint" {
	description = "Read replica endpoint if created, else null"
	value       = try(aws_db_instance.read_replica[0].address, null)
}

