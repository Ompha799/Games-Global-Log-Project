variable "lambda_function_name_save" {
  default = "SaveLogFunction"
}

variable "lambda_function_name_get" {
  default = "GetLogsFunction"
}

variable "lambda_runtime" {
  default = "python3.12"
}

variable "log_table_name" {
  default = "LogTable"
}

variable "region" {
  default = "eu-west-1"
}

variable "account_id" {
  default = "557845476550"
}

variable "tf_state_bucket_name" {
  description = "S3 bucket name for Terraform remote state"
  type        = string
  default = "games-global-tf-state-lock-bucket"
}

variable "tf_lock_table_name" {
  description = "DynamoDB table name for state locking"
  type        = string
  default = "games-global-tf-state-lock-dynamo"
}