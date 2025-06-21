resource "aws_iam_role" "lambda_exec_role" {
  name = "LambdaLogServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_access" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}
resource "aws_dynamodb_table" "log_table" {
  name         = var.log_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ID"
  range_key    = "DateTime"

  attribute {
    name = "ID"
    type = "S"
  }
  attribute {
    name = "DateTime"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }
}
data "archive_file" "save_log_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../functions/save_log"
  output_path = "${path.module}/../functions/save_log.zip"
}

resource "aws_lambda_function" "save_log_function" {
  filename         = data.archive_file.save_log_zip.output_path
  source_code_hash = data.archive_file.save_log_zip.output_base64sha256
  function_name    = var.lambda_function_name_save
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "handler.lambda_handler"
  runtime          = var.lambda_runtime

  environment {
    variables = {
      LOG_TABLE_NAME = aws_dynamodb_table.log_table.name
    }
  }
}

data "archive_file" "get_log_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../functions/get_logs"
  output_path = "${path.module}/../functions/get_logs.zip"
}

resource "aws_lambda_function" "get_logs_function" {
  filename         = data.archive_file.get_log_zip.output_path
  source_code_hash = data.archive_file.get_log_zip.output_base64sha256
  function_name    = var.lambda_function_name_get
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "handler.lambda_handler"
  runtime          = var.lambda_runtime

  environment {
    variables = {
      LOG_TABLE_NAME = aws_dynamodb_table.log_table.name
    }
  }
}
################################api gateway####################################
resource "aws_api_gateway_rest_api" "log_api" {
  name        = "LogServiceAPI"
  description = "API for Simple Log Service"
}

resource "aws_api_gateway_resource" "log_resource" {
  rest_api_id = aws_api_gateway_rest_api.log_api.id
  parent_id   = aws_api_gateway_rest_api.log_api.root_resource_id
  path_part   = "log"
}

resource "aws_api_gateway_method" "post_log" {
  rest_api_id   = aws_api_gateway_rest_api.log_api.id
  resource_id   = aws_api_gateway_resource.log_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "get_log" {
  rest_api_id   = aws_api_gateway_rest_api.log_api.id
  resource_id   = aws_api_gateway_resource.log_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_log_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.log_api.id
  resource_id             = aws_api_gateway_resource.log_resource.id
  http_method             = aws_api_gateway_method.post_log.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.save_log_function.invoke_arn
}

resource "aws_api_gateway_integration" "get_log_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.log_api.id
  resource_id             = aws_api_gateway_resource.log_resource.id
  http_method             = aws_api_gateway_method.get_log.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_logs_function.invoke_arn
}

resource "aws_api_gateway_deployment" "log_api_deployment" {
  depends_on = [
    aws_api_gateway_integration.post_log_lambda,
    aws_api_gateway_integration.get_log_lambda,
  ]
  rest_api_id = aws_api_gateway_rest_api.log_api.id
}
resource "aws_api_gateway_stage" "prod_stage" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.log_api.id
  deployment_id = aws_api_gateway_deployment.log_api_deployment.id
}


resource "aws_lambda_permission" "allow_api_gateway_invoke_save_log" {
  statement_id  = "AllowAPIGatewayInvokeSaveLog"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.save_log_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.log_api.id}/*/POST/log"
}

resource "aws_lambda_permission" "allow_api_gateway_invoke_get_log" {
  statement_id  = "AllowAPIGatewayInvokeGetLog"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_logs_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.log_api.id}/*/GET/log"
}





