# Creates IAM Role for EC2
resource "aws_iam_role" "CodeDeployEC2ServiceRole" {
  name = "CodeDeployEC2ServiceRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = {
      tag-key = "tag-value"
  }
}
# Creates EC2 Instance Profile
resource "aws_iam_instance_profile" "CodeDeployEC2ServiceRole" {
  name = "${var.iam}"
  role = "${aws_iam_role.CodeDeployEC2ServiceRole.name}"
}
# Creates IAM policy and gives access to S3
resource "aws_iam_role_policy" "S3-Images" {
  name = "${var.iam}"
  role = "${aws_iam_role.CodeDeployEC2ServiceRole.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "arn:aws:s3:::${var.S3-image-bucket-name}",
        "arn:aws:s3:::${var.S3-image-bucket-name}/*"
      ]
    }
  ]
}
EOF
}
# Creates IAM policy document
data "aws_iam_policy_document" "iam_policy_document"{
  statement  {
    actions = ["s3:*"]
    effect= "Allow"
    resources = [
      "arn:aws:s3:::${var.S3-image-bucket-name}",
      "arn:aws:s3:::${var.S3-image-bucket-name}/*"
    ]
  }
}
# Attaches S3 Deployment Bucket Policy
resource "aws_iam_role_policy" "CodeDeploy-EC2-S3" {
  name = "CodeDeploy-EC2-S3"
  role = "${aws_iam_role.CodeDeployEC2ServiceRole.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::${var.S3-deployment-bucket}",
                "arn:aws:s3:::${var.S3-deployment-bucket}/*"
            ]
        }
    ]
}
EOF
}
# Attaches Codedeploy service policy to IAM Role
resource "aws_iam_role" "CodeDeployServiceRole" {
  name = "CodeDeployServiceRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
# Attaches policy and role for Code Deploy
resource "aws_iam_role_policy_attachment" "CodeDeployServiceRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = "${aws_iam_role.CodeDeployServiceRole.name}"
}
# Creates Policies for Circle CI
data "aws_iam_user" "CircleCI" {
  user_name = "${var.circleCI-username}"
}
# Creates Policy to upload artifact to S3
resource "aws_iam_policy" "CircleCI-Upload-To-S3" {
  name = "CircleCI-Upload-To-S3"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:Get*",
        "s3:List*"
      ],
      "Resource": [
        "arn:aws:s3:::${var.S3-deployment-bucket}",
        "arn:aws:s3:::${var.S3-deployment-bucket}/*"
      ]
    }
  ]
}
EOF
}
resource "aws_iam_user_policy_attachment" "iam-attachment" {
  user= "${data.aws_iam_user.CircleCI.user_name}"
  policy_arn = "${aws_iam_policy.CircleCI-Upload-To-S3.arn}"
}
# Creates Policy for CircleCI to make deployment calls
resource "aws_iam_policy" "CircleCI-Code-Deploy" {
  name = "CircleCI-Code-Deploy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "codedeploy:RegisterApplicationRevision",
                "codedeploy:GetApplicationRevision"
            ],
            "Resource": [
                "arn:aws:codedeploy:${var.region}:${var.env_account_id}:application:csye6225-webapp"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "codedeploy:CreateDeployment",
                "codedeploy:GetDeployment"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "codedeploy:GetDeploymentConfig"
            ],
            "Resource": [
                "arn:aws:codedeploy:${var.region}:${var.env_account_id}:deploymentconfig:CodeDeployDefault.OneAtATime",
                "arn:aws:codedeploy:${var.region}:${var.env_account_id}:deploymentconfig:CodeDeployDefault.HalfAtATime",
                "arn:aws:codedeploy:${var.region}:${var.env_account_id}:deploymentconfig:CodeDeployDefault.AllAtOnce"
            ]
        }
    ]
}
EOF
}
resource "aws_iam_user_policy_attachment" "deployment_attachment" {
  user= "${data.aws_iam_user.CircleCI.user_name}"
  policy_arn = "${aws_iam_policy.CircleCI-Code-Deploy.arn}"
}
# Creates Policy to Access EC2
resource "aws_iam_policy" "circleci-ec2-ami" {
name = "circleci-ec2-ami"
policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
    "Effect": "Allow",
    "Action": [
      "ec2:AttachVolume",
      "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CopyImage",
        "ec2:CreateImage",
        "ec2:CreateKeypair",
        "ec2:CreateSecurityGroup",
        "ec2:CreateSnapshot",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:DeleteKeyPair",
        "ec2:DeleteSecurityGroup",
        "ec2:DeleteSnapshot",
        "ec2:DeleteVolume",
        "ec2:DeregisterImage",
        "ec2:DescribeImageAttribute",
        "ec2:DescribeImages",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeRegions",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSnapshots",
        "ec2:DescribeSubnets",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DetachVolume",
        "ec2:GetPasswordData",
        "ec2:ModifyImageAttribute",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifySnapshotAttribute",
        "ec2:RegisterImage",
        "ec2:RunInstances",
        "ec2:StopInstances",
        "ec2:TerminateInstances"
      ],
      "Resource": [
        "arn:aws:s3:::${var.S3-deployment-bucket}",
        "arn:aws:s3:::${var.S3-deployment-bucket}/*"
      ]
    }
  ]
}
EOF
}
resource "aws_iam_user_policy_attachment" "ec2_attachment" {
  user= "${data.aws_iam_user.CircleCI.user_name}"
  policy_arn = "${aws_iam_policy.circleci-ec2-ami.arn}"
}
# CloudWatch Agent Policy 
resource "aws_iam_role_policy_attachment" "cloud-watch" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = "${aws_iam_role.CodeDeployEC2ServiceRole.name}"
}
resource "aws_iam_role_policy_attachment" "SNS-acess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
  role       = "${aws_iam_role.CodeDeployEC2ServiceRole.name}"
}
#IAM Lambda role
resource "aws_iam_role" "LambdaRole" {
  name = "LambdaRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
#IAM Lambda Policy 
resource "aws_iam_policy" "LambdaPolicy" {
  name = "LambdaPolicy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "s3:Get*",
          "s3:List*"
          ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:*"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        }
  ]
}
EOF
}
# Attach required policies to Lambda Role
resource "aws_iam_role_policy_attachment" "LambdaRole" {
  policy_arn = "${aws_iam_policy.LambdaPolicy.arn}"
  role       = "${aws_iam_role.LambdaRole.name}"
}
resource "aws_iam_role_policy_attachment" "ExecutionRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = "${aws_iam_role.LambdaRole.name}"
}
resource "aws_iam_role_policy_attachment" "SESFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
  role       = "${aws_iam_role.LambdaRole.name}"
}
resource "aws_iam_role_policy_attachment" "SNSFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
  role       = "${aws_iam_role.LambdaRole.name}"
}
resource "aws_iam_role_policy_attachment" "DynamoDBFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  role       = "${aws_iam_role.LambdaRole.name}"
}
resource "aws_iam_role_policy_attachment" "S3ReadOnlyAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = "${aws_iam_role.LambdaRole.name}"
}
# IAM CircleCI Policy for Lambda
resource "aws_iam_policy" "LambdaS3UploadCircleCI" {
  name = "LambdaS3UploadCircleCI"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:Get*",
        "s3:List*"
      ],
      "Resource": [
        "arn:aws:s3:::${var.S3-email-bucket}",
        "arn:aws:s3:::${var.S3-email-bucket}/*"
      ]
    }
  ]
}
EOF
}
resource "aws_iam_user_policy_attachment" "LambdaCircleCIPolicy" {
  user= "${data.aws_iam_user.CircleCI.user_name}"
  policy_arn = "${aws_iam_policy.LambdaS3UploadCircleCI.arn}"
}
# IAM Policy Email Deployment
resource "aws_iam_policy" "EmailDeployCircleCI" {
  name = "EmailDeployCircleCI"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "lambda:UpdateFunctionCode"
            ],
            "Resource": "${aws_lambda_function.LambdaEmail.arn}"
        }
    ]
}
EOF
}
resource "aws_iam_user_policy_attachment" "LambdaEmailCircleCIPolicy" {
  user= "${data.aws_iam_user.CircleCI.user_name}"
  policy_arn = "${aws_iam_policy.EmailDeployCircleCI.arn}"
}