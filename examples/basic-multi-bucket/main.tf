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
  create_secondary_bucket            = var.create_secondary_bucket
  secondary_bucket_name             = var.secondary_bucket_name
  secondary_bucket_location         = var.secondary_bucket_location
  secondary_storage_class           = var.secondary_storage_class
  secondary_public_access_prevention = var.secondary_public_access_prevention
  secondary_uniform_bucket_level_access = var.secondary_uniform_bucket_level_access
  secondary_force_destroy           = var.secondary_force_destroy
  secondary_versioning_enabled      = var.secondary_versioning_enabled
  secondary_lifecycle_rules         = var.secondary_lifecycle_rules
  secondary_bucket_labels           = var.secondary_bucket_labels
  
  
  # Common labels for all resources
  labels = var.common_labels
}