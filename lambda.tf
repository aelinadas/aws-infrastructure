# Permissions for Lambda Function 
resource "aws_lambda_permission" "SNSPermission" {
    statement_id = "AllowExecutionFromSNS"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.LambdaEmail.arn}"
    principal = "sns.amazonaws.com"
    source_arn = "${aws_sns_topic.password_reset.arn}"
}
# Create Lambda Function
resource "aws_lambda_function" "LambdaEmail" {
  filename = "PasswordTokenGenerator.zip"
  function_name = "LambdaEmail"
  role = "${aws_iam_role.LambdaRole.arn}"
  handler = "PasswordTokenGenerator::handleRequest"
  runtime = "java8"
  memory_size = "512"
  timeout = "15"
  environment {
    variables = {
      Domain = "${var.dns-name}"
    }
  }
}
