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

terraform {
  backend "s3" {
    bucket         = "games-global-tf-state-lock-bucket"
    key            = "simple-log-service/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "games-global-tf-state-lock-dynamo"
    encrypt        = true
  }
}

