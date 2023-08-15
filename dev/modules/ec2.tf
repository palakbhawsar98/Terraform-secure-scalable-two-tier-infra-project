# Open EC2 security group port 22, 80, 443
locals {
  in_ports  = [22, 80, 443]
  out_ports = [0]
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Security group for ec2"
  vpc_id      = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = local.in_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]

    }

  }


  dynamic "egress" {
    for_each = local.out_ports
    content {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  }

  tags = {
    Name = "vpc-sg"
  }

}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_rsa_key" {
  content  = tls_private_key.key.private_key_pem
  filename = "private_rsa_key"
}

resource "aws_key_pair" "public_rsa_key" {
  key_name   = "public_rsa_key"
  public_key = tls_private_key.key.public_key_openssh
}

# Create EC2 instnace in public subnet
resource "aws_instance" "ec2" {
  ami                         = var.instance_ami
  instance_type               = var.instance_size
  key_name                    = aws_key_pair.public_rsa_key.key_name
  count                       = length(var.subnets_count)
  subnet_id                   = element(aws_subnet.vpc_public_subnet.*.id, count.index)
  security_groups             = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.instance_profile.name


  user_data = <<-EOF
#!/bin/bash
sudo apt update -y
sudo apt upgrade -y
sudo apt install awscli -y
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

sudo usermod -aG docker ubuntu

sudo apt install -y git
git clone https://github.com/palakbhawsar98/Python-MySQL-application.git /home/ubuntu/app

# Retrieve database password from AWS Systems Manager Parameter Store
mysql_password=$(aws ssm get-parameter --name mysql_psw --query "Parameter.Value" --output text --with-decryption)

# Pass the password as an environment variable to the Docker container
sudo docker build -t python-app /home/ubuntu/app/
sudo docker run -d -p 80:5000 -e MYSQL_PASSWORD="$mysql_psw" python-app
 
  EOF

  tags = {
    Name = "ec2-${count.index}"
  }

}