output "bucket_id" {
	description = "S3 bucket ID"
	value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
	description = "S3 bucket ARN"
	value       = aws_s3_bucket.this.arn
}

output "bucket_name" {
	description = "S3 bucket name"
	value       = aws_s3_bucket.this.bucket
}

output "lambda_layer_s3_key" {
  value = aws_s3_object.layer_image.key
}
