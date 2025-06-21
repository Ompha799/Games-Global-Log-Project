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