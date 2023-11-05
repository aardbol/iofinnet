locals {
  domain = "aws.malik.pm"
}

resource "aws_route53_zone" "domain" {
  name = local.domain
}
