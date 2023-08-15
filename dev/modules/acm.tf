# Create ACM Certificate for the domain
resource "aws_acm_certificate" "acm_cert" {
  domain_name       = "palakbhawsar.in"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

# Create Route 53 DNS record for ACM certificate validation
resource "aws_route53_record" "route53_cert_dns" {
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.acm_cert.domain_validation_options)[0].resource_record_name
  records         = [tolist(aws_acm_certificate.acm_cert.domain_validation_options)[0].resource_record_value]
  type            = tolist(aws_acm_certificate.acm_cert.domain_validation_options)[0].resource_record_type
  zone_id         = aws_route53_zone.hosted_zone.zone_id
  ttl             = 60
}

# Validate ACM Certificate using Route 53 DNS record
resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.acm_cert.arn
  validation_record_fqdns = [aws_route53_record.route53_cert_dns.fqdn]

  timeouts {
    create = "60m"
  }
}
