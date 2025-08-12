terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# S3 Bucket
resource "aws_s3_bucket" "static_site" {
  bucket        = "day-15-s3-static-website-terraform-007" # Must be globally unique, lowercase, hyphens only
  force_destroy = true
}

# Enable versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.static_site.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Static website config
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.static_site.id

  index_document {
    suffix = "index.html"
  }
}

# Allow public access settings
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.static_site.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Public read bucket policy
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.static_site.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = "${aws_s3_bucket.static_site.arn}/*"
      }
    ]
  })
}

# Upload index.html
resource "aws_s3_object" "index_file" {
  bucket       = aws_s3_bucket.static_site.id
  key          = "index.html"
  source       = "${path.module}/index.html"
  content_type = "text/html"
}

# Upload style.css
resource "aws_s3_object" "style_file" {
  bucket       = aws_s3_bucket.static_site.id
  key          = "style.css"
  source       = "${path.module}/style.css"
  content_type = "text/css"
}

# Output the website URL
output "website_url" {
  value = aws_s3_bucket_website_configuration.website.website_endpoint
}
