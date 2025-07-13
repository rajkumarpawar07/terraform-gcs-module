# outputs.tf - Root Module Outputs for GCS Buckets Child Module
# Author: DevOps Team
# Version: 1.0.0
# Description: Root module outputs that expose child module outputs for GCS buckets

# ============================
# PRIMARY BUCKETS OUTPUTS
# ============================

output "primary_bucket_names" {
  description = "Names of the primary buckets"
  value       = module.gcs_buckets.primary_bucket_names
}

output "primary_bucket_urls" {
  description = "URLs of the primary buckets"
  value       = module.gcs_buckets.primary_bucket_urls
}

output "primary_bucket_self_links" {
  description = "Self links of the primary buckets"
  value       = module.gcs_buckets.primary_bucket_self_links
}

output "primary_buckets_details" {
  description = "Detailed information about primary buckets"
  value       = module.gcs_buckets.primary_buckets_details
}

output "primary_buckets_by_index" {
  description = "Primary buckets organized by their index for incremental access"
  value       = module.gcs_buckets.primary_buckets_by_index
}

# ============================
# SECONDARY BUCKET OUTPUTS
# ============================

output "secondary_bucket_name" {
  description = "Name of the secondary bucket (if created)"
  value       = module.gcs_buckets.secondary_bucket_name
}

output "secondary_bucket_url" {
  description = "URL of the secondary bucket (if created)"
  value       = module.gcs_buckets.secondary_bucket_url
}

output "secondary_bucket_self_link" {
  description = "Self link of the secondary bucket (if created)"
  value       = module.gcs_buckets.secondary_bucket_self_link
}

output "secondary_bucket_details" {
  description = "Detailed information about secondary bucket"
  value       = module.gcs_buckets.secondary_bucket_details
}

# ============================
# COMBINED OUTPUTS
# ============================

output "all_bucket_names" {
  description = "Names of all buckets created (primary + secondary)"
  value       = module.gcs_buckets.all_bucket_names
}

output "all_bucket_urls" {
  description = "URLs of all buckets created (primary + secondary)"
  value       = module.gcs_buckets.all_bucket_urls
}

output "bucket_count" {
  description = "Total number of buckets created"
  value       = module.gcs_buckets.bucket_count
}

# ============================
# VERSIONING OUTPUTS
# ============================

output "versioning_status" {
  description = "Versioning status for all buckets"
  value       = module.gcs_buckets.versioning_status
}

# ============================
# LIFECYCLE POLICY OUTPUTS
# ============================

output "lifecycle_policies_summary" {
  description = "Summary of lifecycle policies applied to buckets"
  value       = module.gcs_buckets.lifecycle_policies_summary
}

# ============================
# SECURITY OUTPUTS
# ============================

output "public_access_prevention_status" {
  description = "Public access prevention status for all buckets"
  value       = module.gcs_buckets.public_access_prevention_status
}

output "uniform_bucket_level_access_status" {
  description = "Uniform bucket level access status for all buckets"
  value       = module.gcs_buckets.uniform_bucket_level_access_status
}

# ============================
# MODULE METADATA OUTPUTS
# ============================

output "module_metadata" {
  description = "Metadata about the module execution"
  value       = module.gcs_buckets.module_metadata
}

# ============================
# CONVENIENCE OUTPUTS
# ============================

output "gcs_module_summary" {
  description = "High-level summary of GCS buckets module deployment"
  value = {
    total_buckets_created     = module.gcs_buckets.bucket_count
    primary_buckets_count     = length(module.gcs_buckets.primary_bucket_names)
    secondary_bucket_created  = module.gcs_buckets.secondary_bucket_name != null
    all_bucket_names         = module.gcs_buckets.all_bucket_names
    module_version           = module.gcs_buckets.module_metadata.module_version
    environment             = module.gcs_buckets.module_metadata.environment
    project_id              = module.gcs_buckets.module_metadata.project_id
  }
}

# ============================
# FORMATTED OUTPUTS FOR EXTERNAL USE
# ============================

output "bucket_endpoints" {
  description = "Formatted bucket endpoints for external applications"
  value = {
    for bucket_name in module.gcs_buckets.all_bucket_names : bucket_name => {
      gs_url    = "gs://${bucket_name}"
      http_url  = "https://storage.googleapis.com/${bucket_name}"
      api_url   = "https://storage.googleapis.com/storage/v1/b/${bucket_name}"
    }
  }
}

output "bucket_access_info" {
  description = "Bucket access information for applications"
  value = {
    bucket_names              = module.gcs_buckets.all_bucket_names
    bucket_urls              = module.gcs_buckets.all_bucket_urls
    versioning_enabled_buckets = [
      for bucket_name, status in module.gcs_buckets.versioning_status : 
      bucket_name if status.versioning_enabled
    ]
    public_access_prevented_buckets = [
      for bucket_name, status in module.gcs_buckets.public_access_prevention_status : 
      bucket_name if status.public_access_prevention == "enforced"
    ]
  }
}