############################################
# S3 MODULE - Application Bucket
############################################

resource "aws_s3_bucket" "this" {
	bucket_prefix = var.bucket_prefix
	force_destroy = var.force_destroy
	tags = {
		Name = "${var.project_name}-${var.environment}-${var.bucket_prefix}-bucket"
	}
}

resource "aws_s3_bucket_versioning" "this" {
	bucket = aws_s3_bucket.this.id
	versioning_configuration { status = var.versioning_enabled ? "Enabled" : "Suspended" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
	bucket = aws_s3_bucket.this.id
	rule {
		apply_server_side_encryption_by_default {
			sse_algorithm = "AES256"
		}
	}
}

