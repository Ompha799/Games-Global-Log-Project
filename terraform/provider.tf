provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket         = "games-global-tf-state-lock-bucket"
    key            = "simple-log-service/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    use_lockfile   = true

  }
}

