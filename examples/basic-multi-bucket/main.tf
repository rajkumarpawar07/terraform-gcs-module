terraform {
  required_version = ">= 1.0"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "gcs_buckets" {
  source = "git::https://github.com/rajkumarpawar07/terraform-gcs-module.git?ref=v1.1.0"
  
  project_id  = var.project_id
  environment = var.environment
  
  # creating two Primary bucket configuration
  bucket_configs = var.bucket_configs
  
  # (Optional) second bucket for disaster recovery
  create_secondary_bucket = var.create_secondary_bucket
  secondary_bucket_config = var.secondary_bucket_config
  lifecycle_rules = var.secondary_lifecycle_rules
  
  # Common labels for all resources
  common_labels = var.common_labels
}