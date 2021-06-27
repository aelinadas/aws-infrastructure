variable "region"{  
}
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
#RDS Variables
variable "rds_instance_identifier" {
}
variable "database_name" {
}
variable "database_password" {
}
variable "database_user" {
}
variable "ami_instance" {  
}
variable "ssh_key_name" {
  type = string
}
variable "iam" {
  type = string
  default = "EC2-CSYE6225"
}
variable "S3-image-bucket-name" {
  type = string
}
variable "S3-deployment-bucket" {
  type = string
}
variable "circleCI-username" {
}
variable "env_account_id" {
}
variable "dns-name" {
  type = string
}
variable "S3-email-bucket" {
  type = string
}
variable "certificate-arn" {
  type = string 
}