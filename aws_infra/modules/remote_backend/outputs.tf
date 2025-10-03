output "tf_state_bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}

output "tf_state_lock_table" {
  value = aws_dynamodb_table.terraform_locks.name
}