# Terraform Module: cloudfont_static_website

## Description

A module to create a CloudFront distribution with custom subdomains and TLS encryption

## Features

- Creates S3 buckets per environment
- Creates CloudFront distribution with custom subdomains
- Creates TLS certificate for custom subdomains
- Creates Route53 records for custom subdomains
- 

## Usage

### Example 1: Basic Usage

```hcl
module "[module_instance_name]" {
  source =  "../../4-modules/cloudfront_static_website"

  # Input variables go here
  variable1 = "value1"
  variable2 = "value2"
}
