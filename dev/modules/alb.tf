# Create security group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"
  description = "Security group for ALB"

  vpc_id = aws_vpc.vpc.id

  # Ingress rule to allow incoming HTTP traffic (port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rule to allow incoming HTTP traffic (port 443)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an Application Load Balancer (ALB)
resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.vpc_public_subnet[*].id
}


# Create a Target Group for ALB
resource "aws_lb_target_group" "my_target_group_https" {
  name     = "my-target-group-https"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

}

# Create an ALB listener for HTTP traffic
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Default response from ALB"
      status_code  = "200"
    }
  }
  certificate_arn = aws_acm_certificate.acm_cert.arn # Provide your ACM certificate ARN

}

# Create ALB listener rules
resource "aws_lb_listener_rule" "alb_listener_rule" {
  listener_arn = aws_lb_listener.alb_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group_https.arn
  }

  condition {
    path_pattern {
      values = ["/signup"]
    }
  }

  priority = 1
}

resource "aws_lb_listener_rule" "alb_listener_rule_signin" {
  listener_arn = aws_lb_listener.alb_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group_https.arn
  }

  condition {
    path_pattern {
      values = ["/signin"]
    }
  }

  priority = 2
}

resource "aws_lb_listener_rule" "alb_listener_rule_dashboard" {
  listener_arn = aws_lb_listener.alb_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group_https.arn
  }

  condition {
    path_pattern {
      values = ["/dashboard"]
    }
  }

  priority = 3
}

# Attach certificate in ALB
resource "aws_lb_listener_certificate" "alb_listener_certificate" {
  listener_arn    = aws_lb_listener.alb_listener.arn
  certificate_arn = aws_acm_certificate.acm_cert.arn
}

# Attach EC2 instances to the Application Load Balancer (ALB) target group
resource "aws_lb_target_group_attachment" "attachment_instance_1" {
  target_group_arn = aws_lb_target_group.my_target_group_https.arn
  count            = length(var.availability_zone)
  target_id        = aws_instance.ec2[count.index].id
  port             = 80
}

