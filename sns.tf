# Add SNS Topic
resource "aws_sns_topic" "password_reset" {
  name = "password_reset"
}
# Attach Lambda Role to SNS
resource "aws_sns_topic_subscription" "password_reset_subscription" {
  topic_arn = "${aws_sns_topic.password_reset.arn}"
  protocol = "lambda"
  endpoint = "${aws_lambda_function.LambdaEmail.arn}"
}