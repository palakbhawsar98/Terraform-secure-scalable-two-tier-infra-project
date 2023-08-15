# Create parameter store for DB password
resource "aws_ssm_parameter" "mysql_password" {
  name  = "mysql_psw"
  type  = "SecureString"
  value = "12345678"
}
