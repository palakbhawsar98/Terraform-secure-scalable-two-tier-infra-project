# Create hosted zone for your domain
resource "aws_route53_zone" "hosted_zone" {
  name = "palakbhawsar.in"
}

# Add A name record in route53 for ALB
resource "aws_route53_record" "alb_a_record" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "palakbhawsar.in" # Root domain
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = false
  }
}