terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


variable "access_key" {}
variable "secret_key" {}

# Configure the AWS Provider
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = "ap-south-1"
}

# create an S3 bucket
resource "aws_s3_bucket" "bucket" {
  bucket = "lavisha-bucket-123"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}


# Enable security
resource "aws_s3_bucket_ownership_controls" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.bucket]

  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}

# Encrypt the objects on rest
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Host static website
resource "aws_s3_bucket_website_configuration" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_object" "index" {
  bucket                 = aws_s3_bucket.bucket.id
  key                    = "index.html"
  source                 = "web pages\\index.html"
  content_type           = "text/html"
  server_side_encryption = "AES256"
}


resource "aws_s3_object" "error" {
  bucket                 = aws_s3_bucket.bucket.id
  key                    = "error.html"
  source                 = "web pages\\error.html"
  content_type           = "text/html"
  server_side_encryption = "AES256"
}


#cloudfront configuration
resource "aws_cloudfront_origin_access_control" "s3originAccess" {
  name                              = "s3originAccess"
  description                       = "s3originAccess Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

locals {
  s3_origin_id = "myS3Origin"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.s3originAccess.id
    origin_id                = local.s3_origin_id
  }

  enabled = true #to enable it when it starts

  is_ipv6_enabled     = true
  default_root_object = "index.html" #root doc to display to client


  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"] # how to get objects from bucket
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id # origin of object identified using s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "https-only" # protocol used by user to access the content
  }


  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = "dev"
  }

  viewer_certificate {
    cloudfront_default_certificate = true # required for usser to access the content over cloudfront domain
  }
}


# bucket policy
resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account_cloudfront.json
}

data "aws_iam_policy_document" "allow_access_from_another_account_cloudfront" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*"
    ]
  }
}
