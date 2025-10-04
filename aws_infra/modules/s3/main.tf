############################################
# S3 MODULE - Application Bucket
############################################

resource "aws_s3_bucket" "this" {
	bucket_prefix = var.bucket_prefix
	force_destroy = var.force_destroy
	tags = merge(local.merged_tags, {
		Name = "${var.project_name}-${var.environment}-${var.bucket_prefix}-bucket"
	})
}

# Enable S3 to Send Events to EventBridge
resource "aws_s3_bucket_notification" "s3_to_eventbridge" {
  bucket = aws_s3_bucket.this.id

  eventbridge = true
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

resource "aws_s3_bucket_lifecycle_configuration" "grocery_s3_lifecycle" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "expire-old-avatars"
    status = var.lifecycle_status

    filter {
      prefix = var.avatar_prefix
    }

    expiration {
      days = var.expiration_days
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_block" {
    bucket = aws_s3_bucket.this.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Allow EC2 to access specific folders in S3
      {
        Sid       = "AllowEC2Access"
        Effect    = "Allow"
        Principal = {
          AWS = var.ec2_iam_role_arn # Allow the EC2 role
        }
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.this.arn
      },
      {
        Sid       = "AllowEC2ObjectAccess"
        Effect    = "Allow"
        Principal = {
          AWS = var.ec2_iam_role_arn # Allow the EC2 role
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.this.arn}/${var.avatar_prefix}*"
      },

      # Allow Lambda to access specific folders in S3
      {
        Sid       = "AllowLambdaAccess"
        Effect    = "Allow"
        Principal = {
          AWS = var.lambda_iam_role_arn # Allow the Lambda function role
        }
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.this.arn
      },
      {
        Sid       = "AllowLambdaObjectAccess"
        Effect    = "Allow"
        Principal = {
          AWS = var.lambda_iam_role_arn # Allow the Lambda function role
        }
        Action = [
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.this.arn}/${var.db_dump_prefix}*"
      }
    ]
  })
}

resource "aws_s3_object" "avatar_image" {
  bucket = aws_s3_bucket.this.id
  key    = "${var.avatar_prefix}${var.avatar_filename}"
  source = var.avatar_path
}

resource "aws_s3_object" "layer_image" {
  bucket = aws_s3_bucket.this.id
  key    = "${var.layer_prefix}${var.layer_filename}"
  source = var.layer_path
}

