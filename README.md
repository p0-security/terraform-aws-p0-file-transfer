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
module "file_transfer_bucket" {
  source  = "p0-security/p0-file-transfer/aws"
  version = "0.1.0"
}

resource "p0_file_transfer" "main" {
  account_id    = module.file_transfer_bucket.account_id
  bucket_name   = module.file_transfer_bucket.bucket_name
  region        = module.file_transfer_bucket.region
  aws_partition = module.file_transfer_bucket.aws_partition
  depends_on    = [module.file_transfer_bucket]
}
```

For multi-account deployments, use a provider alias per account:

```terraform
provider "aws" {
  alias  = "account_a"
  region = "us-east-1"
  assume_role { role_arn = "arn:aws:iam::111111111111:role/DeployRole" }
}

provider "aws" {
  alias  = "account_b"
  region = "us-east-1"
  assume_role { role_arn = "arn:aws:iam::222222222222:role/DeployRole" }
}

module "file_transfer_account_a" {
  source    = "p0-security/p0-file-transfer/aws"
  version   = "0.1.0"
  providers = { aws = aws.account_a }
}

module "file_transfer_account_b" {
  source    = "p0-security/p0-file-transfer/aws"
  version   = "0.1.0"
  providers = { aws = aws.account_b }
}
```

Run `terraform init` and `terraform apply`.

## Inputs

This module has no input variables. The bucket name is derived automatically from the AWS account ID of the caller.

## Outputs

| Name            | Description                                                                               |
| --------------- | ----------------------------------------------------------------------------------------- |
| `bucket_name`   | The bucket name, for use as the `bucket_name` input to the `p0_file_transfer` resource   |
| `bucket_arn`    | The ARN of the file transfer S3 bucket                                                    |
| `account_id`    | The AWS account ID, for use as the `account_id` input to the `p0_file_transfer` resource |
| `region`        | The AWS region, for use as the `region` input to the `p0_file_transfer` resource         |
| `aws_partition` | The AWS partition, for use as the `aws_partition` input to the `p0_file_transfer` resource |

## Requirements

| Name | Version   |
| ---- | --------- |
| aws  | >= 5.42.0 |
