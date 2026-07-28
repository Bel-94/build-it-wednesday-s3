# =============================================================================
# outputs.tf
# WHY THIS FILE EXISTS:
# Outputs are values Terraform prints after a successful apply.
# They are the "receipt" of what was built — especially useful for beginners
# who need the website URL without hunting through the AWS Console.
# =============================================================================

output "bucket_name" {
  description = "Name of the S3 bucket that stores the website objects."
  value       = aws_s3_bucket.website.id
}

output "website_endpoint" {
  description = <<-EOT
    S3 website endpoint hostname (no scheme).
    Combine with http:// to open the site in a browser.
    Note: the S3 website endpoint serves HTTP only — HTTPS requires CloudFront.
  EOT
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
}

output "website_domain" {
  description = "Website domain reported by the S3 website configuration (same host as the endpoint)."
  value       = aws_s3_bucket_website_configuration.website.website_domain
}

output "website_url" {
  description = "Ready-to-open HTTP URL for the static website."
  value       = "http://${aws_s3_bucket_website_configuration.website.website_endpoint}"
}
