# Creates Dynamo Table
resource "aws_dynamodb_table" "table" {
    name = "csye6225"
    billing_mode = "PROVISIONED"
    read_capacity = 20
    write_capacity = 20
    hash_key = "id"
    attribute {
      name = "id"
      type = "S"
    }
}