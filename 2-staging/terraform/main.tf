locals {
  environment = "staging"
  endpoints   = ["auth", "info", "customers"]
  domain      = "aws.malik.pm"

  custom_tags = {
    application = "staticwebsite"
  }
}

module "static_website" {
  source = "../../4-modules/cloudfront_static_website"

  providers = {
    aws.us-east-1 = aws.us-east-1
  }
  endpoints         = local.endpoints
  environment       = local.environment
  domain            = local.domain
  custom_tags       = local.custom_tags
  cloudfront_region = local.region
  bucket_prefix     = "iofinnet-bucket"
}
