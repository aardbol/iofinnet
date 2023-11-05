module "terraform_state" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket = "iofinnet-tfstate-global"

  attach_deny_incorrect_encryption_headers = true
  attach_deny_insecure_transport_policy    = true
  attach_require_latest_tls_policy         = true
  attach_deny_unencrypted_object_uploads   = true

#  attach_policy = true
#  policy = jsonencode({
#    Version = "2012-10-17",
#    Statement = [
#      {
#        Effect    = "Allow",
#        Action    = "s3:ListBucket",
#        Resource  = "arn:aws:s3:::iofinnet-tfstate-global"
#        Principal = aws_iam_group.devops.arn
#      },
#      {
#        Effect    = "Allow",
#        Action    = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
#        Resource  = "arn:aws:s3:::iofinnet-tfstate-global/global.tfstate"
#        Principal = aws_iam_group.devops.arn
#      }
#    ]
#  })

  versioning = {
    status = "Enabled"
  }

  tags = { application = "shared", team = "devops" }
}

#terraform {
#  backend "s3" {
#    bucket  = "iofinnet-tfstate-global"
#    key     = "global.tfstate"
#    region  = "eu-central-1"
#  }
#}
