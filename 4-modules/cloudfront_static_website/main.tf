# S3 buckets
# They are AWS-S3 encrypted by default

data "aws_canonical_user_id" "me" {}
data "aws_cloudfront_log_delivery_canonical_user_id" "cloudfront" {}

module "bucket_logs" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket = "${var.bucket_prefix}logs-${var.environment}"

  attach_access_log_delivery_policy        = true
  attach_deny_incorrect_encryption_headers = true
  attach_deny_insecure_transport_policy    = true
  attach_require_latest_tls_policy         = true
  attach_deny_unencrypted_object_uploads   = true

  # ACL is required for Cloudfront logs
  # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html#AccessLogsBucketAndFileOwnership
  grant = [{
    type       = "CanonicalUser"
    permission = "FULL_CONTROL"
    id         = data.aws_canonical_user_id.me.id
    }, {
    type       = "CanonicalUser"
    permission = "FULL_CONTROL"
    id         = data.aws_cloudfront_log_delivery_canonical_user_id.cloudfront.id
  }]
  object_ownership         = "BucketOwnerPreferred"
  control_object_ownership = true
  force_destroy            = true

  versioning = {
    status = "Enabled"
  }

  tags = { application = "shared" }
}

module "bucket_website" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  for_each = toset(var.endpoints)

  bucket = "${var.bucket_prefix}${index(var.endpoints, each.key) + 1}-${var.environment}"

  attach_access_log_delivery_policy        = true
  attach_deny_incorrect_encryption_headers = true
  attach_deny_insecure_transport_policy    = true
  attach_require_latest_tls_policy         = true
  attach_deny_unencrypted_object_uploads   = true

  versioning = {
    status = "Enabled"
  }
  force_destroy = true

  tags = merge(var.custom_tags, { endpoint = each.key })
}

# Domain and certificate generation

data "aws_route53_zone" "domain_zone" {
  name = var.domain
}

resource "aws_route53_record" "endpoints" {
  for_each = toset(var.endpoints)

  name    = "${each.key}.${var.environment}"
  type    = "A"
  zone_id = data.aws_route53_zone.domain_zone.id
  alias {
    evaluate_target_health = false
    name                   = module.cloudfront_website[each.key].cloudfront_distribution_domain_name
    zone_id                = module.cloudfront_website[each.key].cloudfront_distribution_hosted_zone_id
  }
}

module "website_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  providers = {
    aws = aws.us-east-1
  }

  for_each = toset(var.endpoints)

  domain_name         = "${each.key}.${var.environment}.${var.domain}"
  zone_id             = data.aws_route53_zone.domain_zone.id
  validation_method   = "DNS"
  wait_for_validation = true
  key_algorithm       = var.acm_key_algorithm

  tags = merge(var.custom_tags, { endpoint = each.key })
}

# Cloudfront distribution

resource "aws_cloudfront_origin_access_control" "s3_oac" {
  # TODO per env
  name                              = "s3_oac_${var.environment}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

module "cloudfront_website" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "~> 3.0"

  for_each = toset(var.endpoints)

  aliases = ["${each.key}.${var.environment}.${var.domain}"]

  comment                        = "CloudFront_Distribution${index(var.endpoints, each.key) + 1}_${var.environment}"
  enabled                        = true
  is_ipv6_enabled                = true
  http_version                   = "http2and3"
  price_class                    = var.environment == "prod" ? "PriceClass_All" : "PriceClass_200"
  retain_on_delete               = false
  wait_for_deployment            = false
  create_monitoring_subscription = var.create_monitoring_subscription

  default_cache_behavior = {
    target_origin_id       = module.bucket_website[each.key].s3_bucket_bucket_regional_domain_name
    viewer_protocol_policy = var.cache_viewer_protocol_policy
    min_ttl                = var.cache_min_ttl
    default_ttl            = var.cache_default_ttl
    max_ttl                = var.cache_max_ttl
    # This is id for SecurityHeadersPolicy
    #    response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03"
  }
  logging_config = {
    bucket = module.bucket_logs.s3_bucket_bucket_domain_name
    prefix = "cloudfront"
  }
  origin = {
    s3_oac = {
      domain_name              = module.bucket_website[each.key].s3_bucket_bucket_regional_domain_name
      origin_id                = module.bucket_website[each.key].s3_bucket_bucket_regional_domain_name
      origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id

      origin_shield = {
        enabled              = true
        origin_shield_region = var.cloudfront_region
      }
    }
  }
  viewer_certificate = {
    acm_certificate_arn      = module.website_acm[each.key].acm_certificate_arn
    minimum_protocol_version = var.minimum_protocol_version
    ssl_support_method       = var.ssl_support_method
  }
  tags = merge(var.custom_tags, { endpoint = each.key })

  depends_on = [aws_cloudfront_origin_access_control.s3_oac]
}
