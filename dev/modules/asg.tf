resource "aws_launch_template" "ec2_launch_template" {
  name_prefix   = "ec2-launch-template"
  image_id      = var.instance_ami
  instance_type = "t2.micro"
  key_name      = aws_key_pair.public_rsa_key.key_name

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 20
      delete_on_termination = true
      volume_type           = "gp2"
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ec2-instance"
    }
  }
user_data = filebase64("user-data.sh")

}

# Create an Auto Scaling Group
resource "aws_autoscaling_group" "my_asg" {
  name = "my-asg"
  launch_template {
    id      = aws_launch_template.ec2_launch_template.id
    version = "$Latest"
  }
  min_size         = 2
  max_size         = 4
  desired_capacity = 2

  vpc_zone_identifier = aws_subnet.vpc_public_subnet[*].id

  target_group_arns = [aws_lb_target_group.my_target_group_https.arn]

  tag {
    key                 = "Name"
    value               = "ec2-instance"
    propagate_at_launch = true
  }
}
