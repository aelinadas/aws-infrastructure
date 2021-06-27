resource "aws_lb" "LoadBalancer" {
  name               = "loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.LoadbalancerSG.id}"]
  subnets            = ["${aws_subnet.subnet.*.id[0]}","${aws_subnet.subnet.*.id[1]}","${aws_subnet.subnet.*.id[2]}"]
}
resource "aws_lb_listener" "Listener" {
  load_balancer_arn = "${aws_lb.LoadBalancer.arn}"
  port              = "443"
  protocol          = "HTTPS"
  
  default_action {
    target_group_arn = "${aws_lb_target_group.TargetGroup.arn}"
    type = "forward"
  }
  certificate_arn = "${var.certificate-arn}"
}
resource "aws_lb_target_group" "TargetGroup" {
  name     = "t-grp"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.main.id}"
  stickiness {
    type = "lb_cookie"
    cookie_duration = "180"
    enabled = true
  }
  target_type = "instance"
}

# Creates Security Group configuration for port 80, 8080 and 443
resource "aws_security_group" "LoadbalancerSG" {
  name   = "LoadbalancerSG"
  vpc_id = "${aws_vpc.main.id}"
  ingress {
    from_port  = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port  = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "tomcat"
  }
  ingress {
    from_port  = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}