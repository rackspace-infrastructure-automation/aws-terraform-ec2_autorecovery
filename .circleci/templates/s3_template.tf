provider "aws" {
  version = "~> 1.2"
  region  = "us-west-2"
}

resource "aws_s3_bucket" "s3_backend" {
  bucket        = "((GENERATED_BUCKET_NAME))"
  acl           = "private"
  force_destroy = true

  tags {
    Environment = "CircleCI Testing"
  }
}
