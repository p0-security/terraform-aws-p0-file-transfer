# S3 bucket for the P0 `file-transfer` command. Files land under
# uploads/<userKey>/<transferId>/ and are removed after transfer; the
# lifecycle rules below are the safety net for leftovers.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.42.0"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  bucket_name = "p0-transfers-${data.aws_caller_identity.current.account_id}"
  tags = {
    managed-by = "terraform"
  }
}

resource "aws_s3_bucket" "file_transfer" {
  bucket = local.bucket_name
  tags   = local.tags
}

resource "aws_s3_bucket_ownership_controls" "file_transfer" {
  bucket = aws_s3_bucket.file_transfer.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "file_transfer" {
  bucket                  = aws_s3_bucket.file_transfer.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "file_transfer" {
  bucket = aws_s3_bucket.file_transfer.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "file_transfer" {
  bucket = aws_s3_bucket.file_transfer.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_policy" "file_transfer" {
  bucket = aws_s3_bucket.file_transfer.id
  # Both resources mutate the same bucket; applying them in parallel can fail with a transient conflict, so force the access block to settle before we put the bucket policy.
  depends_on = [aws_s3_bucket_public_access_block.file_transfer]
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.file_transfer.arn,
          "${aws_s3_bucket.file_transfer.arn}/*",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
    ]
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "file_transfer" {
  bucket = aws_s3_bucket.file_transfer.id

  rule {
    id     = "expire-uploads"
    status = "Enabled"
    filter {
      prefix = "uploads/"
    }
    expiration {
      days = 1
    }
  }

  rule {
    id     = "abort-incomplete-multipart-uploads"
    status = "Enabled"
    filter {}
    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}
