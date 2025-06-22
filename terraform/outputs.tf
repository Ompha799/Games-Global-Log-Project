output "save_log_function_arn" {
  value = aws_lambda_function.save_log_function.arn
}

output "get_logs_function_arn" {
  value = aws_lambda_function.get_logs_function.arn
}

output "invoke_url" {
  value = "${aws_api_gateway_stage.prod_stage.invoke_url}/log"
}

output "log_api_key" {
  value = aws_api_gateway_api_key.log_api_key.value
  sensitive = true
}