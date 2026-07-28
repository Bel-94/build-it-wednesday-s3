# =============================================================================
# variables.tf
# WHY THIS FILE EXISTS:
# Variables make the configuration reusable. Instead of hard-coding names and
# regions, learners pass values via terraform.tfvars (or -var on the CLI).
# That is a core Infrastructure as Code practice: one codebase, many environments.
# =============================================================================

variable "aws_region" {
  description = "AWS region where the S3 static website bucket will be created."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Short project name used in resource naming and default tags."
  type        = string
  default     = "biw-s3-static-website"
}

variable "environment" {
  description = "Environment label (for example: lab, dev, prod). Used in tags and bucket naming."
  type        = string
  default     = "lab"
}

variable "bucket_name" {
  description = <<-EOT
    Globally unique S3 bucket name.
    S3 bucket names must be unique across ALL AWS accounts worldwide.
    Leave null to let Terraform generate a unique name from project + environment + random suffix.
  EOT
  type        = string
  default     = null
}
