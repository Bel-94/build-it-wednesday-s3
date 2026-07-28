# =============================================================================
# main.tf
# WHY THIS FILE EXISTS:
# This is the "heart" of the project. Every AWS resource needed to host a
# static website on S3 is declared here. Terraform reads these declarations
# and creates (or updates) the real infrastructure to match.
#
# Teaching tip: read each resource's comments BEFORE the resource block.
# Understanding WHY a resource exists is more important than memorizing HCL.
# =============================================================================

# -----------------------------------------------------------------------------
# Random suffix for a globally unique bucket name
# WHY: S3 bucket names are a global namespace. Two learners cannot share the
# same name. A short random suffix avoids collisions without manual renaming.
# -----------------------------------------------------------------------------
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# -----------------------------------------------------------------------------
# Local values
# WHY: locals keep naming logic in one place so resources stay readable.
# -----------------------------------------------------------------------------
locals {
  # Prefer an explicit bucket_name if provided; otherwise build a unique name.
  bucket_name = coalesce(
    var.bucket_name,
    "${var.project_name}-${var.environment}-${random_id.bucket_suffix.hex}"
  )

  # Path to the local website folder (relative to this terraform/ directory).
  website_root = "${path.module}/../website"

  # MIME types Terraform should set when uploading objects.
  # WHY content_type matters: browsers use it to decide how to render a file.
  # If CSS is uploaded as binary/octet-stream, styles may not apply.
  content_types = {
    ".html" = "text/html"
    ".css"  = "text/css"
    ".js"   = "application/javascript"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".gif"  = "image/gif"
    ".svg"  = "image/svg+xml"
    ".ico"  = "image/x-icon"
    ".webp" = "image/webp"
  }

  # Collect every file under website/ so Terraform can upload them as objects.
  # Object KEY = relative path from website/ (for example: assets/logo.svg).
  # A "prefix" like assets/ is just part of the key — S3 has no real folders.
  website_files = fileset(local.website_root, "**/*")
}

# -----------------------------------------------------------------------------
# Amazon S3 Bucket
# WHY THIS RESOURCE EXISTS:
# The bucket is the durable object store that holds every website file.
# For a static site, the bucket replaces a traditional web server's disk.
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "website" {
  bucket = local.bucket_name

  # Force destroy helps learners clean up lab buckets that still contain objects.
  # In real production, many teams set this to false to prevent accidental deletes.
  force_destroy = true

  tags = {
    Name = local.bucket_name
    Role = "static-website-origin"
  }
}

# -----------------------------------------------------------------------------
# Bucket Ownership Controls
# WHY THIS RESOURCE EXISTS:
# Modern S3 best practice is BucketOwnerEnforced (ACLs disabled).
# Access is controlled with bucket policies and IAM — not object ACLs.
# That simplifies permissions and matches current AWS recommendations.
# -----------------------------------------------------------------------------
resource "aws_s3_bucket_ownership_controls" "website" {
  bucket = aws_s3_bucket.website.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# -----------------------------------------------------------------------------
# Public Access Block
# WHY THIS RESOURCE EXISTS:
# By default, AWS blocks ALL public access to new buckets. That is a strong
# security default for private data lakes and app backends.
#
# For classic S3 Static Website Hosting (without CloudFront), anonymous users
# must be able to read objects via a bucket policy. Therefore we intentionally
# turn OFF the settings that would block public policies / public buckets.
#
# SECURITY TRADE-OFF (learn this well):
#   - Lab / beginner path: public-read bucket policy + website endpoint
#   - Production path: keep the bucket PRIVATE and put CloudFront + OAC in front
#
# We disable blocking only as much as needed for the website policy to work.
# -----------------------------------------------------------------------------
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  # Allow a bucket policy that grants public GetObject.
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  depends_on = [aws_s3_bucket_ownership_controls.website]
}

# -----------------------------------------------------------------------------
# Static Website Hosting Configuration
# WHY THIS RESOURCE EXISTS:
# Enabling website hosting tells S3 to serve objects like a web server:
#   - index_document: returned for the site root (/)
#   - error_document: returned when a key is missing (custom 404 page)
#
# The website endpoint is DIFFERENT from the S3 REST API endpoint.
# Example website endpoint:
#   http://BUCKET.s3-website-REGION.amazonaws.com
# -----------------------------------------------------------------------------
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# -----------------------------------------------------------------------------
# Bucket Policy (least privilege for public website reads)
# WHY THIS RESOURCE EXISTS:
# With ACLs disabled, a bucket policy is how we grant anonymous readers
# permission to download website objects (s3:GetObject).
#
# We grant ONLY s3:GetObject on objects inside this bucket.
# We do NOT grant ListBucket, PutObject, DeleteObject, or admin actions.
# That keeps the public surface area as small as possible for this pattern.
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "public_read" {
  statement {
    sid = "PublicReadGetObject"

    # Anonymous internet users ("*") may read objects — required for public sites.
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    # "/*" means every object key in the bucket (index.html, styles.css, assets/...).
    resources = [
      "${aws_s3_bucket.website.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id
  policy = data.aws_iam_policy_document.public_read.json

  # Public Access Block must be updated BEFORE a public policy can be attached.
  depends_on = [
    aws_s3_bucket_public_access_block.website,
    aws_s3_bucket_website_configuration.website,
  ]
}

# -----------------------------------------------------------------------------
# Upload website files as S3 Objects
# WHY THIS RESOURCE EXISTS:
# Infrastructure as Code should deploy BOTH the bucket AND the content when
# practical. Uploading with Terraform means `terraform apply` produces a
# working site — no manual console uploads afterward.
#
# KEY CONCEPTS for learners:
#   - Object  = a file stored in S3
#   - Key     = the full path/name of that object (for example: assets/logo.svg)
#   - Prefix  = the "folder-like" portion of a key (for example: assets/)
# -----------------------------------------------------------------------------
resource "aws_s3_object" "website_files" {
  for_each = local.website_files

  bucket = aws_s3_bucket.website.id

  # Object key mirrors the relative file path under website/.
  key = each.value

  # Source is the local file Terraform will upload.
  source = "${local.website_root}/${each.value}"

  # etag detects content changes so Terraform re-uploads when a file changes.
  etag = filemd5("${local.website_root}/${each.value}")

  # Set the correct Content-Type from the file extension.
  content_type = lookup(
    local.content_types,
    lower(regex("\\.[^.]+$", each.value)),
    "application/octet-stream"
  )

  depends_on = [aws_s3_bucket_policy.website]
}
