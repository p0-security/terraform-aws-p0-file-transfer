# terraform-aws-p0-file-transfer

Provisions the customer-owned S3 bucket that P0 uses to broker temporary, audited
file transfers to your AWS EC2 instances via the `p0 file-transfer` command.

Files land under `uploads/<userKey>/<transferId>/` and are removed after transfer.
The bucket is created secure-by-default: all public access blocked, SSE-S3
encryption, ACLs disabled, and lifecycle rules that expire `uploads/` objects and
abort incomplete multipart uploads after one day.

> **Prerequisite:** AWS SSH (`p0_ssh_aws`) must be installed for the same AWS
> account before file transfer can be requested.

## Usage

```terraform
locals {
  bucket_name = "p0-transfers-123456789012"
}

module "file_transfer_bucket" {
  source  = "p0-security/p0-file-transfer/aws"
  version = "0.1.0"

  bucket_name = local.bucket_name
}

resource "p0_file_transfer" "main" {
  account_id    = "123456789012"
  bucket_name   = module.file_transfer_bucket.bucket_name
  region        = "us-east-1"
  aws_partition = "aws"
  depends_on    = [module.file_transfer_bucket]
}
```

Run `terraform init` and `terraform apply`.

## Inputs

| Name          | Description                                                              | Type     | Required |
| ------------- | ------------------------------------------------------------------------ | -------- | :------: |
| `bucket_name` | Name of the S3 bucket for P0 file transfers (DNS-style, no s3:// prefix) | `string` |   yes    |

## Outputs

| Name          | Description                                                                       |
| ------------- | --------------------------------------------------------------------------------- |
| `bucket_id`   | The name of the file transfer S3 bucket                                           |
| `bucket_arn`  | The ARN of the file transfer S3 bucket                                            |
| `bucket_name` | The bucket name, for use as the `bucket_name` input to the `p0_file_transfer` resource |

## Requirements

| Name | Version   |
| ---- | --------- |
| aws  | >= 5.42.0 |
