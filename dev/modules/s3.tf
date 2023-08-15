# Create S3 to store remote state
resource "aws_s3_bucket" "dev-remote-state-bucket" {
  bucket = "dev-remote-state-bucket"
  versioning {
    enabled = true
  }
  tags = {
    Name = "S3 Remote Terraform State Store"
  }
}
