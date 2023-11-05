output "domain_ns" {
  value = aws_route53_zone.domain.name_servers
}

output "domain_zone_id" {
  value = aws_route53_zone.domain.zone_id
}
