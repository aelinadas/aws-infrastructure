# Creates EC2 instance
# resource "aws_instance" "webapp" {
#   ami = "${var.ami_instance}"
#   instance_type = "t2.micro"
#   key_name = "${var.ssh_key_name}"	
#   security_groups = ["${aws_security_group.application.id}"]
#   subnet_id = "${aws_subnet.subnet.*.id[0]}"
#   associate_public_ip_address = true
#   iam_instance_profile = "${aws_iam_instance_profile.CodeDeployEC2ServiceRole.name}"
#   tags = {
#     Name = "EC2 Instance"
#   }
#   user_data = <<-EOF
#     #!/bin/bash
#     touch /home/ubuntu/applicationConfig.properties
#     echo "bucketName=${var.S3-image-bucket-name}" >> /home/ubuntu/applicationConfig.properties
#     echo "hostName=${aws_db_instance.default.endpoint}" >> /home/ubuntu/applicationConfig.properties
#     echo "dbName=${var.database_name}" >> /home/ubuntu/applicationConfig.properties
#     echo "userName=${var.database_user}" >> /home/ubuntu/applicationConfig.properties
#     echo "password=${var.database_password}" >> /home/ubuntu/applicationConfig.properties
#     EOF
#   root_block_device {
#     volume_size = 20
#     volume_type = "gp2"
#   }
#   depends_on = [aws_db_instance.default]
# }