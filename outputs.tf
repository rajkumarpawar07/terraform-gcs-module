# outputs.tf - Cleaned GCS Module Outputs
# Author: DevOps Team
# Version: 1.0.0

# ============================
# PRIMARY BUCKETS OUTPUTS
# ============================

output "primary_bucket_names" {
  description = "==> Names of the primary buckets"
  value       = [for bucket in google_storage_bucket.primary_buckets : bucket.name]
}

output "primary_bucket_urls" {
  description = "==> URLs of the primary buckets"
  value       = [for bucket in google_storage_bucket.primary_buckets : bucket.url]
}

output "primary_bucket_self_links" {
  description = "==> Self links of the primary buckets"
  value       = [for bucket in google_storage_bucket.primary_buckets : bucket.self_link]
}


# ============================
# SECONDARY BUCKET OUTPUTS
# ============================

output "secondary_bucket_name" {
  description = "==> Name of the secondary bucket (if created)"
  value       = var.create_secondary_bucket ? google_storage_bucket.secondary_bucket[0].name : null
}

output "secondary_bucket_url" {
  description = "==> URL of the secondary bucket (if created)"
  value       = var.create_secondary_bucket ? google_storage_bucket.secondary_bucket[0].url : null
}

output "secondary_bucket_self_link" {
  description = "==> Self link of the secondary bucket (if created)"
  value       = var.create_secondary_bucket ? google_storage_bucket.secondary_bucket[0].self_link : null
}


# ============================
# COMBINED OUTPUTS
# ============================

output "all_bucket_names" {
  description = "==> Names of all buckets created (primary + secondary)"
  value = concat(
    [for bucket in google_storage_bucket.primary_buckets : bucket.name],
    var.create_secondary_bucket ? [google_storage_bucket.secondary_bucket[0].name] : []
  )
}

output "all_bucket_urls" {
  description = "==> URLs of all buckets created (primary + secondary)"
  value = concat(
    [for bucket in google_storage_bucket.primary_buckets : bucket.url],
    var.create_secondary_bucket ? [google_storage_bucket.secondary_bucket[0].url] : []
  )
}

output "bucket_count" {
  description = "==> Total number of buckets created"
  value = length(google_storage_bucket.primary_buckets) + (var.create_secondary_bucket ? 1 : 0)
}


# ============================
# SECURITY OUTPUTS
# ============================

output "public_access_prevention_status" {
  description = "==> Public access prevention status for all buckets"
  value = merge(
    {
      for name, bucket in google_storage_bucket.primary_buckets : name => {
        public_access_prevention = bucket.public_access_prevention
        bucket_type             = "primary"
      }
    },
    var.create_secondary_bucket ? {
      "${google_storage_bucket.secondary_bucket[0].name}" = {
        public_access_prevention = google_storage_bucket.secondary_bucket[0].public_access_prevention
        bucket_type             = "secondary"
      }
    } : {}
  )
}

output "uniform_bucket_level_access_status" {
  description = "==> Uniform bucket level access status for all buckets"
  value = merge(
    {
      for name, bucket in google_storage_bucket.primary_buckets : name => {
        uniform_bucket_level_access = bucket.uniform_bucket_level_access
        bucket_type                = "primary"
      }
    },
    var.create_secondary_bucket ? {
      "${google_storage_bucket.secondary_bucket[0].name}" = {
        uniform_bucket_level_access = google_storage_bucket.secondary_bucket[0].uniform_bucket_level_access
        bucket_type                = "secondary"
      }
    } : {}
  )
}



# ============================
# MODULE METADATA OUTPUT
# ============================

output "module_metadata" {
  description = "Metadata about the module execution"
  value = {
    module_version               = "1.0.0"
    terraform_version            = "~> 1.0"
    google_provider_version      = "~> 4.5"
    google_beta_provider_version = "~> 4.5"
    buckets_created              = length(google_storage_bucket.primary_buckets) + (var.create_secondary_bucket ? 1 : 0)
    primary_buckets_count        = length(google_storage_bucket.primary_buckets)
    secondary_bucket_created     = var.create_secondary_bucket
    environment                  = var.environment
    project_id                   = var.project_id
    common_labels                = local.common_labels
  }
}
