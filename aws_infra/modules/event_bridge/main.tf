############################################
# EVENT BRIDGE MODULE - S3 Trigger to StepFn
############################################

resource "aws_cloudwatch_event_rule" "s3_upload_event" {
  name        = var.rule_name
  description = "Trigger Step Function when SQL dump is uploaded"
  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["Object Created"]
    detail = {
      bucket = { name = [var.bucket_name] }
      object = { key = [var.db_dump_s3_key] }
    }
  })
  tags = merge(local.merged_tags, { Name = "${var.project_name}-${var.environment}-s3-dump-event" })
}

resource "aws_cloudwatch_event_target" "step_function_trigger_s3" {
  rule      = aws_cloudwatch_event_rule.s3_upload_event.name
  target_id = "StepFunctionTriggerS3"
  arn       = var.state_machine_arn
  role_arn  = var.eventbridge_role_arn
}
