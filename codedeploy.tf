# Creates Code Deployment Application
resource "aws_codedeploy_app" "csye6225-webapp" {
  name = "csye6225-webapp"
}

# Creates Code Deployment Group
resource "aws_codedeploy_deployment_group" "csye6225-deployment-group" {
  app_name              = "${aws_codedeploy_app.csye6225-webapp.name}"
  deployment_group_name = "csye6225-webapp-deployment"
  service_role_arn      = "${aws_iam_role.CodeDeployServiceRole.arn}"
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  autoscaling_groups = ["${aws_autoscaling_group.AutoscalingGroup.name}"]
  deployment_style {
    deployment_type = "IN_PLACE"
  }
  ec2_tag_filter {
    key   = "Name"
    type  = "KEY_AND_VALUE"
    value = "EC2 Instance"
  }
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}