provider "aws" {
  region = "eu-west-1"
}

resource "aws_s3_bucket" "tf_state_bucket" {
  bucket = var.tf_state_bucket_name
}

resource "aws_dynamodb_table" "tf_lock_table" {
  name         = var.tf_lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}