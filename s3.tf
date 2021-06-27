#Creates of S3 bucket for Images
resource "aws_s3_bucket" "webapp-aelina" {
  bucket = "${var.S3-image-bucket-name}"
  acl    = "private"
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  lifecycle_rule {
    enabled = true
    transition {
      days = 30
      storage_class = "STANDARD_IA"
    }
  }
}
# Creates S3 bucket policy to restrict public access
resource "aws_s3_bucket_public_access_block" "webapp-aelina" {
  bucket = "${aws_s3_bucket.webapp-aelina.id}"

  block_public_acls   = false
  ignore_public_acls = false
  block_public_policy = true
  restrict_public_buckets = true

  depends_on = [
    aws_s3_bucket_policy.webapp-aelina
  ]
}
# Creates Bucket Policy for Images Bucket
resource "aws_s3_bucket_policy" "webapp-aelina" {
  bucket = "${aws_s3_bucket.webapp-aelina.id}"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [ 
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": [
            "Acct#1",
            "Acct#2"
          ]
        },
        "Action": "s3:*",
        "Resource": [
          "arn:aws:s3:::${var.S3-image-bucket-name}",
          "arn:aws:s3:::${var.S3-image-bucket-name}/*"
        ]
      }
    ]
}
POLICY
}
# Creates S3 Bucket for Deployment Artifacts
resource "aws_s3_bucket" "S3-deployment-bucket" {
  bucket = "${var.S3-deployment-bucket}"
  acl    = "private"
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  lifecycle_rule {
    enabled = true
    transition {
      days = 30
      storage_class = "STANDARD_IA"
    }
  }
}
# Creates S3 bucket policy to restrict public access
resource "aws_s3_bucket_public_access_block" "S3-deployment-bucket" {
  bucket = "${aws_s3_bucket.S3-deployment-bucket.id}"

  block_public_acls   = false
  ignore_public_acls = false
  block_public_policy = true
  restrict_public_buckets = true

}
# Creates S3 Lambda Bucket for Email Trigger
resource "aws_s3_bucket" "S3EmailBucket" {
  bucket = "${var.S3-email-bucket}"
  acl    = "private"
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  lifecycle_rule {
    enabled = true
    transition {
      days = 30
      storage_class = "STANDARD_IA"
    }
  }
}
# Creates S3 bucket policy to restrict public access
resource "aws_s3_bucket_public_access_block" "S3EmailBucket" {
  bucket = "${aws_s3_bucket.S3EmailBucket.id}"

  block_public_acls   = false
  ignore_public_acls = false
  block_public_policy = true
  restrict_public_buckets = true

}
# S3 Bucket Notificatio for Email Trigger
# resource "aws_s3_bucket_notification" "bucket_notification" {
#   bucket = "${aws_s3_bucket.S3EmailBucket.id}"

#   lambda_function {
#     lambda_function_arn = "${aws_lambda_function.LambdaEmail.arn}"
#     events              = ["s3:ObjectCreated:*"]
#     filter_prefix       = "AWSLogs/"
#     filter_suffix       = ".log"
#   }

#   depends_on = [aws_lambda_permission.S3BucketPermission]
# }