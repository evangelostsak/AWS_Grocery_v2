locals {
  enforced_tags = {
    Project     = var.project_name
    Environment = var.environment
    Terraform   = "true"
    ManagedBy   = "terraform"
  }
  merged_tags = merge(local.enforced_tags, var.common_tags)


  state_machine_definition = {
    Comment = "Step function to trigger Lambda after RDS is ready and SQL dump is in S3."
    StartAt = "WaitForRDS"
    States = {
      WaitForRDS = {
        Type       = "Task"
        Resource   = "arn:aws:states:::aws-sdk:rds:describeDBInstances"
        Parameters = { DbInstanceIdentifier = var.db_identifier }
        ResultPath = "$.output"
        Next       = "LogRDSOutput"
        Catch      = [{ ErrorEquals = ["States.ALL"], Next = "HandleRDSFailure" }]
      }
      LogRDSOutput = { Type = "Pass", ResultPath = "$.output", Next = "CheckRDSStatus" }
      CheckRDSStatus = {
        Type    = "Choice"
        Choices = [{ Variable = "$.output.output.DbInstances[0].DbInstanceStatus", StringEquals = "available", Next = "CheckS3File" }]
        Default = "HandleRDSFailure"
      }
      CheckS3File = {
        Type       = "Task"
        Resource   = "arn:aws:states:::aws-sdk:s3:headObject"
        Parameters = { Bucket = var.bucket_name, Key = var.db_dump_s3_key }
        Next       = "CheckS3FileExists"
        Catch      = [{ ErrorEquals = ["States.ALL"], Next = "HandleS3Failure" }]
      }
      CheckS3FileExists = {
        Type    = "Choice"
        Choices = [{ Variable = "$.ContentLength", NumericGreaterThan = 0, Next = "TriggerLambda" }]
        Default = "WaitForS3File"
      }
      WaitForS3File       = { Type = "Wait", Seconds = var.wait_seconds, Next = "CheckS3File" }
      TriggerLambda       = { Type = "Task", Resource = var.lambda_function_arn, End = true, Catch = [{ ErrorEquals = ["States.ALL"], Next = "HandleLambdaFailure" }] }
      HandleRDSFailure    = { Type = "Fail", Cause = "RDS instance check failed.", Error = "RDSFailure" }
      HandleS3Failure     = { Type = "Fail", Cause = "S3 file check failed.", Error = "S3Failure" }
      HandleLambdaFailure = { Type = "Fail", Cause = "Lambda function execution failed.", Error = "LambdaFailure" }
    }
  }
}
