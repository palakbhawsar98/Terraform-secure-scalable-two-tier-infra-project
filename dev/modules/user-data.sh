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
