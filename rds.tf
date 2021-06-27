# Creates RDS subnet
resource "aws_db_subnet_group" "rds_subnet" {
  name = "application"
  description = "RDS subnet group"
  subnet_ids  = "${aws_subnet.subnet.*.id}"

  tags ={
    Name = "DB subnet group"
  }
}
# Creates RDS Security Group
resource "aws_security_group" "rds" {
  name  = "database"
  description = "RDS MySQL server"
  vpc_id = "${aws_vpc.main.id}"
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = ["${aws_security_group.application.id}"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creates RDS MySQL database instance
resource "aws_db_instance" "default" {
  identifier = "${var.rds_instance_identifier}"
  allocated_storage = "20"
  engine = "mysql"
  engine_version = "5.7.28"
  instance_class = "db.t3.micro"
  multi_az = false
  name = "${var.database_name}"
  username = "${var.database_user}"
  password = "${var.database_password}"
  db_subnet_group_name = "${aws_db_subnet_group.rds_subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.rds.id}"]
  publicly_accessible = "false"
  skip_final_snapshot = true
  deletion_protection = false
  delete_automated_backups = true
  storage_encrypted = true
  parameter_group_name = "${aws_db_parameter_group.DB-Group.name}"
}
# SSL DB Parameter Group
resource "aws_db_parameter_group" "DB-Group" {
  name   = "ssl-db-parameter"
  family = "mysql5.7"

  parameter {
    name  = "performance_schema"
    value = "1"
    apply_method = "pending-reboot"
  }
}