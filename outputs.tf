output "bucket_id" {
  description = "The name of the file transfer S3 bucket"
  value       = aws_s3_bucket.file_transfer.id
}

output "bucket_arn" {
  description = "The ARN of the file transfer S3 bucket"
  value       = aws_s3_bucket.file_transfer.arn
}

output "bucket_name" {
  description = "The name of the file transfer S3 bucket, for use as the bucket_name input to the p0_file_transfer resource"
  value       = aws_s3_bucket.file_transfer.bucket
}
