# =============================================================================
# versions.tf
# WHY THIS FILE EXISTS:
# Terraform needs to know WHICH versions of Terraform and providers are allowed.
# Pinning versions keeps deployments predictable — a newer provider release will
# not silently change behavior and break a beginner lab or a production apply.
# =============================================================================

terraform {
  # Require Terraform 1.5+ so learners use a modern, stable CLI.
  required_version = ">= 1.5.0"

  required_providers {
    # The AWS provider translates Terraform resources into AWS API calls.
    # Pinning to major version 5 keeps the configuration compatible with
    # current S3 resource types (aws_s3_bucket_website_configuration, etc.).
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    # Random provider creates a short unique suffix for the bucket name.
    # WHY: S3 names are globally unique — collisions are common in shared labs.
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}
