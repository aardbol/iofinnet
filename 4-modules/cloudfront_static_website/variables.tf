variable "bucket_prefix" {
  default     = ""
  description = "The prefix for the bucket name"
}

variable "environment" {
  type        = string
  description = "The environment: dev, staging, or prod"
  validation {
    condition     = can(regex("^(dev|staging|prod)$", var.environment))
    error_message = "Invalid environment. Has to be dev, staging or prod"
  }
}

variable "endpoints" {
  type        = list(string)
  description = "The endpoints to create in Route53, CloudFront and S3"
}

variable "domain" {
  description = "The domain name for the CloudFront distributions and TLS certificates"
  validation {
    condition     = can(regex("^([a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,}$", var.domain))
    error_message = "Invalid domain name. Please provide a valid domain name."
  }
}

variable "custom_tags" {
  type        = map(string)
  default     = {}
  description = "(Optional) A map of tags to add to all resources"
}

variable "acm_key_algorithm" {
  default     = "RSA_2048"
  description = "The key algorithm to use for the ACM certificate generation"
  validation {
    condition     = can(regex("^(RSA_2048|EC_prime256v1|EC_secp384r1)$", var.acm_key_algorithm))
    error_message = "Invalid acm_key_algorithm. Has to be RSA_2048, EC_prime256v1 or EC_secp384r1"
  }
}

# CloudFront

variable "cloudfront_region" {
  description = "The AWS region where to create CloudFront distributions"
}

variable "minimum_protocol_version" {
  type        = string
  description = "The minimum version of the TLS protocol that you want CloudFront to use for HTTPS connections. "
  default     = "TLSv1.2_2018"
  validation {
    condition     = can(regex("^TLSv1\\.[2-3](_\\d{4})?$", var.minimum_protocol_version))
    error_message = "Invalid minimum_protocol_version. Has to be minimim TLSv1.2"
  }
}

variable "ssl_support_method" {
  type        = string
  description = "Specifies how you want CloudFront to serve HTTPS requests."
  default     = "sni-only"
  validation {
    condition     = can(regex("^(vip|sni-only)$", var.ssl_support_method))
    error_message = "Invalid ssl_support_method. Has to be vip or sni-only"
  }
}

variable "cache_min_ttl" {
  type        = number
  description = "The minimum amount of time that you want objects to stay in CloudFront caches before CloudFront queries your origin to see whether the object has been updated."
  default     = 0
}

variable "cache_default_ttl" {
  type        = number
  description = "The default amount of time (in seconds) that an object is in a CloudFront cache before CloudFront forwards another request in the absence of an Cache-Control max-age or Expires header."
  default     = 3600
}

variable "cache_max_ttl" {
  type        = number
  description = "The maximum amount of time (in seconds) that an object is in a CloudFront cache before CloudFront forwards another request to your origin to determine whether the object has been updated. Only effective in the presence of Cache-Control max-age, Cache-Control s-maxage, and Expires headers"
  default     = 86400
}

variable "cache_viewer_protocol_policy" {
  type        = string
  description = "Use this element to specify the protocol that users can use to access the files in the origin specified by TargetOriginId when a request matches the path pattern in PathPattern."
  default     = "https-only"
  validation {
    condition     = can(regex("^(allow-all|https-only|redirect-to-https)$", var.cache_viewer_protocol_policy))
    error_message = "Invalid cache_viewer_protocol_policy. Has to be allow-all, https-only or redirect-to-https"
  }
}

variable "create_monitoring_subscription" {
  type        = bool
  description = "Whether to create a CloudWatch subscription to monitor the CloudFront distribution"
  default     = true
}
