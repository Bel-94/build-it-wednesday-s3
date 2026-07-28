# =============================================================================
# providers.tf
# WHY THIS FILE EXISTS:
# A provider tells Terraform WHICH cloud (or SaaS) it should talk to.
# Without a provider, Terraform does not know how to create an S3 bucket.
#
# Credentials are NOT stored here. Terraform uses the same credential chain
# as the AWS CLI (environment variables, shared credentials file, or IAM roles).
# That is intentional — secrets belong outside source control.
# =============================================================================

provider "aws" {
  # Region where the S3 bucket (and website endpoint) will live.
  # Learners can override this with the aws_region variable.
  region = var.aws_region

  # Default tags are applied to every taggable resource created by this provider.
  # WHY: tagging helps with cost tracking, ownership, and cleanup in real accounts.
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Series      = "BuildItWednesday"
    }
  }
}
