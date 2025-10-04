############################################
# LAMBDA MODULE - Function, Layer, StepFn
############################################

# Create a Lambda layer
resource "aws_lambda_layer_version" "my_layer" {
  layer_name          = "boto3-psycopg2-layer"
  description         = "My custom Lambda layer"
  compatible_runtimes = ["python3.12"]

  s3_bucket = var.bucket_name
  s3_key    = var.lambda_layer_s3_key
}

# Lambda function 
resource "aws_lambda_function" "db_populator" {
  function_name = "${var.project_name}-${var.environment}-db-populator"
  role          = var.iam_lambda_role_arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  timeout       = 60
  filename      = var.lambda_zip_file
  source_code_hash = filebase64sha256(var.lambda_zip_file)
  layers        = [aws_lambda_layer_version.my_layer.arn]

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.lambda_security_group_id]
  }

  environment {
    variables = {
      POSTGRES_HOST     = var.rds_host
      POSTGRES_PORT     = var.rds_port
      POSTGRES_DB       = var.db_name
      POSTGRES_USER     = var.db_username
      POSTGRES_PASSWORD = var.rds_password
      S3_BUCKET_NAME    = var.bucket_name
      S3_OBJECT_KEY     = var.db_dump_s3_key
      S3_REGION         = var.region
    }
  }

  tags = merge(local.merged_tags, {
    Name = "${var.project_name}-${var.environment}-lambda-db-populator"
    Type = "lambda-function"
  })
}