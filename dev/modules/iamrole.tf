# Create IAM role for EC2 instnace
resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "rds_ssm_policy" {
  name = "rds_ssm_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "rds:*",
        "ssm:*"
      ],
      Resource = "*"
    }]
  })
}

resource "aws_iam_policy_attachment" "ec2_role_attachment" {
  name       = "ec2_role_attachment"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.rds_ssm_policy.arn
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "instance_profile"
  role = aws_iam_role.ec2_role.name
}