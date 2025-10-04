output "state_machine_arn" {
	description = "ARN of the Step Functions state machine"
	value       = aws_sfn_state_machine.db_restore_sfn.arn
}
