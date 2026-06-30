output "bucket_name" {
  description = "The name of the file transfer S3 bucket, for use as the bucket_name input to the p0_file_transfer resource"
  value       = aws_s3_bucket.file_transfer.bucket
}

output "bucket_arn" {
  description = "The ARN of the file transfer S3 bucket"
  value       = aws_s3_bucket.file_transfer.arn
}

output "account_id" {
  description = "The AWS account ID the bucket was created in, for use as the account_id input to the p0_file_transfer resource"
  value       = data.aws_caller_identity.current.account_id
}

output "region" {
  description = "The AWS region the bucket was created in, for use as the region input to the p0_file_transfer resource"
  value       = aws_s3_bucket.file_transfer.region
}

output "aws_partition" {
  description = "The AWS partition the bucket resides in, for use as the aws_partition input to the p0_file_transfer resource"
  value       = data.aws_partition.current.partition
}
