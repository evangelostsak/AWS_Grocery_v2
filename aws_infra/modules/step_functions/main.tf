############################################
# STEP FUNCTIONS MODULE - State Machine
############################################

resource "aws_sfn_state_machine" "db_restore_sfn" {
  name     = var.state_machine_name
  role_arn = var.sfn_role_arn

  definition = jsonencode(local.state_machine_definition)

  logging_configuration {
    log_destination        = "${var.step_function_log_group_arn}:*"
    level                  = "ALL"
    include_execution_data = true
  }

  tags = merge(local.merged_tags, {
    Name = "${var.project_name}-${var.environment}-sfn-db-restore"
    Type = "state-machine"
  })
}