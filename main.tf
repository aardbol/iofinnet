locals {
  domain = "aws.domain.com"
}

resource "aws_route53_zone" "domain" {
  name = local.domain
}
