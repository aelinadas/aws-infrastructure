#Autoscale EC2 Instance
resource "aws_launch_configuration" "LaunchConfiguration" {
  name_prefix  = "asg_launch_config_"
  image_id = "${var.ami_instance}"
  instance_type = "t2.micro"
  key_name = "${var.ssh_key_name}"
  associate_public_ip_address = true
  user_data = <<-EOF
    #!/bin/bash
    touch /home/ubuntu/applicationConfig.properties
    echo "bucketName=${var.S3-image-bucket-name}" >> /home/ubuntu/applicationConfig.properties
    echo "hostName=${aws_db_instance.default.endpoint}" >> /home/ubuntu/applicationConfig.properties
    echo "dbName=${var.database_name}" >> /home/ubuntu/applicationConfig.properties
    echo "userName=${var.database_user}" >> /home/ubuntu/applicationConfig.properties
    echo "password=${var.database_password}" >> /home/ubuntu/applicationConfig.properties
    EOF
  iam_instance_profile = "${aws_iam_instance_profile.CodeDeployEC2ServiceRole.name}"
  security_groups = ["${aws_security_group.application.id}"]

  lifecycle {
    create_before_destroy = true
  }
}
#Add autoscaling group to Launch Configuration
resource "aws_autoscaling_group" "AutoscalingGroup" {
  name = "autoscaling-grp"
  launch_configuration = "${aws_launch_configuration.LaunchConfiguration.id}"
  min_size = 2
  max_size = 5
  desired_capacity = 2
  vpc_zone_identifier = ["${aws_subnet.subnet.*.id[0]}"]
  default_cooldown = 60
  health_check_type = "EC2"
  target_group_arns = ["${aws_lb_target_group.TargetGroup.arn}"]
  lifecycle {
    create_before_destroy = true
  }
  tag {
    key = "Name"
    value = "EC2"
    propagate_at_launch = true
  }
}
#Autoscaling Policy Scale Up
resource "aws_autoscaling_policy" "ScaleUpPolicy" {
  name = "ScaleUpPolicy"
  cooldown = 60
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  autoscaling_group_name = "${aws_autoscaling_group.AutoscalingGroup.name}"
}
#Autoscaling Policy Scale Down
resource "aws_autoscaling_policy" "ScaleDownPolicy" {
  name = "ScaleDownPolicy"
  cooldown = 60
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  autoscaling_group_name = "${aws_autoscaling_group.AutoscalingGroup.name}"
}
#Autoscaling for CloudWatch Alarms for High CPU usage
resource "aws_cloudwatch_metric_alarm" "HighCPUAlarm" {
  alarm_name = "HighCPUAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = "1"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "180"
  statistic = "Average"
  threshold = "8"
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.AutoscalingGroup.name}"
  }
  alarm_description = "EC2 CPU utilization for high usage"
  alarm_actions     = ["${aws_autoscaling_policy.ScaleUpPolicy.arn}"]
}
#Autoscaling for CloudWatch Alarms for Low CPU usage
resource "aws_cloudwatch_metric_alarm" "CPUAlarmLow" {
  alarm_name = "CPUAlarmLow"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = "1"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "180"
  statistic = "Average"
  threshold = "3"
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.AutoscalingGroup.name}"
  }
  alarm_description = "EC2 CPU utilization for low usage"
  alarm_actions = ["${aws_autoscaling_policy.ScaleDownPolicy.arn}"]
}