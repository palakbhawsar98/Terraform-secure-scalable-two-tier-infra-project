output "public_ip" {
  value = aws_instance.ec2.*.public_ip

}

output "private_key" {
  value     = tls_private_key.key.private_key_pem
  sensitive = true

}

output "certificate_arn" {
  value = aws_acm_certificate.acm_cert.arn
}

output "zone_nameservers" {
  value = aws_route53_zone.hosted_zone.name_servers
}


output "endpoint" {
  value = aws_db_instance.mysql_db.endpoint
}
