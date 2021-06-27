provider "aws" {
  region = "${var.region}"
}
# Creates VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  enable_classiclink_dns_support = true
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name = "vpc"
  }
}
# Creates Internet Gateway
resource "aws_internet_gateway" "csye6225_a4_gateway" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "gateway"
  }
}
# Creates Subnet for VPC and RDS
resource "aws_subnet" "subnet" {
  count = "${length(data.aws_availability_zones.available.names)}"
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "10.0.${length(data.aws_availability_zones.available.names) + count.index}.0/24"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"

  tags = {
    Name = "public-${element(data.aws_availability_zones.available.names, count.index)}"
  }
}
# Creates Route Table configuration
resource "aws_route_table" "route_table" {
  vpc_id = "${aws_vpc.main.id}"
  tags = {
    Name = "route_table"
  }
}
resource "aws_route" "route" {
  route_table_id                = "${aws_route_table.route_table.id}"
  destination_cidr_block        = "0.0.0.0/0"
  gateway_id                    = "${aws_internet_gateway.csye6225_a4_gateway.id}"

}
resource "aws_route_table_association" "association" {
  count                   = "${length(data.aws_availability_zones.available.names)}"  
  subnet_id               = "${element(aws_subnet.subnet.*.id, count.index)}"
  route_table_id          = "${aws_route_table.route_table.id}"
}
# Creates Security Group configuration for port 80, 22, 8080 and 443
resource "aws_security_group" "application" {
  name   = "application"
  vpc_id = "${aws_vpc.main.id}"
  ingress {
    from_port  = 80
    to_port = 80
    protocol = "tcp"
    # cidr_blocks = ["0.0.0.0/0"]
    security_groups = ["${aws_security_group.LoadbalancerSG.id}"]
  }
  # ingress {
  #   from_port  = 22
  #   to_port = 22
  #   protocol = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  ingress {
    from_port  = 8080
    to_port = 8080
    protocol = "tcp"
    # cidr_blocks = ["0.0.0.0/0"]
    description = "tomcat"
    security_groups = ["${aws_security_group.LoadbalancerSG.id}"]
  }
  ingress {
    from_port  = 443
    to_port = 443
    protocol = "tcp"
    # cidr_blocks = ["0.0.0.0/0"]
    security_groups = ["${aws_security_group.LoadbalancerSG.id}"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}