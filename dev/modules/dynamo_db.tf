# Create Dynamo DB to acquire lock on remote state
resource "aws_dynamodb_table" "terraform-state-lock" {
  name           = "terraform-state-lock"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    "Name" = "DynamoDB Terraform State Lock Table"
  }
}