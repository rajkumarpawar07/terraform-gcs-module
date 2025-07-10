# outputs.tf - GCS Module Outputs
# Author: DevOps Team
# Version: 1.0.0
# Description: Output values for GCS buckets module with versioning and lifecycle policies

# ============================
# PRIMARY BUCKETS OUTPUTS
# ============================

output "primary_bucket_names" {
  description = "Names of the primary buckets"
  value       = [for bucket in google_storage_bucket.primary_buckets : bucket.name]
}

output "primary_bucket_urls" {
  description = "URLs of the primary buckets"
  value       = [for bucket in google_storage_bucket.primary_buckets : bucket.url]
}

output "primary_bucket_self_links" {
  description = "Self links of the primary buckets"
  value       = [for bucket in google_storage_bucket.primary_buckets : bucket.self_link]
}

output "primary_buckets_details" {
  description = "Detailed information about primary buckets"
  value = {
    for name, bucket in google_storage_bucket.primary_buckets : name => {
      name                        = bucket.name
      location                    = bucket.location
      storage_class              = bucket.storage_class
      url                        = bucket.url
      self_link                  = bucket.self_link
      versioning_enabled         = bucket.versioning[0].enabled
      public_access_prevention   = bucket.public_access_prevention
      uniform_bucket_level_access = bucket.uniform_bucket_level_access
      labels                     = bucket.labels
      lifecycle_rules_count      = length(bucket.lifecycle_rule)
      
    }
  }
}

output "primary_buckets_by_index" {
  description = "Primary buckets organized by their index for incremental access"
  value = {
    for name, bucket in google_storage_bucket.primary_buckets : 
    local.bucket_configs[name].index => {
      name                        = bucket.name
      location                    = bucket.location
      storage_class              = bucket.storage_class
      url                        = bucket.url
      self_link                  = bucket.self_link
      versioning_enabled         = bucket.versioning[0].enabled
      public_access_prevention   = bucket.public_access_prevention
      uniform_bucket_level_access = bucket.uniform_bucket_level_access
      labels                     = bucket.labels
      index                      = local.bucket_configs[name].index
    }
  }
}

# ============================
# SECONDARY BUCKET OUTPUTS
# ============================

output "secondary_bucket_name" {
  description = "Name of the secondary bucket (if created)"
  value       = var.create_secondary_bucket ? google_storage_bucket.secondary_bucket[0].name : null
}

output "secondary_bucket_url" {
  description = "URL of the secondary bucket (if created)"
  value       = var.create_secondary_bucket ? google_storage_bucket.secondary_bucket[0].url : null
}

output "secondary_bucket_self_link" {
  description = "Self link of the secondary bucket (if created)"
  value       = var.create_secondary_bucket ? google_storage_bucket.secondary_bucket[0].self_link : null
}

output "secondary_bucket_details" {
  description = "Detailed information about secondary bucket"
  value = var.create_secondary_bucket ? {
    name                        = google_storage_bucket.secondary_bucket[0].name
    location                    = google_storage_bucket.secondary_bucket[0].location
    storage_class              = google_storage_bucket.secondary_bucket[0].storage_class
    url                        = google_storage_bucket.secondary_bucket[0].url
    self_link                  = google_storage_bucket.secondary_bucket[0].self_link
    versioning_enabled         = google_storage_bucket.secondary_bucket[0].versioning[0].enabled
    public_access_prevention   = google_storage_bucket.secondary_bucket[0].public_access_prevention
    uniform_bucket_level_access = google_storage_bucket.secondary_bucket[0].uniform_bucket_level_access
    labels                     = google_storage_bucket.secondary_bucket[0].labels
    lifecycle_rules_count      = length(google_storage_bucket.secondary_bucket[0].lifecycle_rule)
  } : null
}

# ============================
# COMBINED OUTPUTS
# ============================

output "all_bucket_names" {
  description = "Names of all buckets created (primary + secondary)"
  value = concat(
    [for bucket in google_storage_bucket.primary_buckets : bucket.name],
    var.create_secondary_bucket ? [google_storage_bucket.secondary_bucket[0].name] : []
  )
}

output "all_bucket_urls" {
  description = "URLs of all buckets created (primary + secondary)"
  value = concat(
    [for bucket in google_storage_bucket.primary_buckets : bucket.url],
    var.create_secondary_bucket ? [google_storage_bucket.secondary_bucket[0].url] : []
  )
}

output "bucket_count" {
  description = "Total number of buckets created"
  value = length(google_storage_bucket.primary_buckets) + (var.create_secondary_bucket ? 1 : 0)
}

# ============================
# VERSIONING OUTPUTS
# ============================

# output "versioning_enabled_buckets" {
#   description = "List of buckets with versioning enabled"
#   value = concat(
#     [for bucket in google_storage_bucket.primary_buckets : bucket.name if bucket.versioning[0].enabled],
#     var.create_secondary_bucket && google_storage_bucket.secondary_bucket[0].versioning[0].enabled ? [google_storage_bucket.secondary_bucket[0].name] : []
#   )
# }

output "versioning_status" {
  description = "Versioning status for all buckets"
  value = merge(
    {
      for name, bucket in google_storage_bucket.primary_buckets : name => {
        versioning_enabled = bucket.versioning[0].enabled
        bucket_type       = "primary"
      }
    },
    var.create_secondary_bucket ? {
      "${google_storage_bucket.secondary_bucket[0].name}" = {
        versioning_enabled = google_storage_bucket.secondary_bucket[0].versioning[0].enabled
        bucket_type       = "secondary"
      }
    } : {}
  )
}

# ============================
# LIFECYCLE POLICY OUTPUTS
# ============================

output "lifecycle_policies_summary" {
  description = "Summary of lifecycle policies applied to buckets"
  value = merge(
    {
      for name, bucket in google_storage_bucket.primary_buckets : name => {
        lifecycle_rules_count = length(bucket.lifecycle_rule)
        has_custom_rules     = local.bucket_configs[name].lifecycle_rules != null
        bucket_type          = "primary"
      }
    },
    var.create_secondary_bucket ? {
      "${google_storage_bucket.secondary_bucket[0].name}" = {
        lifecycle_rules_count = length(google_storage_bucket.secondary_bucket[0].lifecycle_rule)
        has_custom_rules     = var.secondary_lifecycle_rules != null
        bucket_type          = "secondary"
      }
    } : {}
  )
}

# ============================
# SECURITY OUTPUTS
# ============================

output "public_access_prevention_status" {
  description = "Public access prevention status for all buckets"
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
  description = "Uniform bucket level access status for all buckets"
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
# IAM OUTPUTS
# ============================

output "iam_bindings" {
  description = "IAM bindings applied to buckets"
  value = {
    for key, binding in google_storage_bucket_iam_binding.bucket_iam_bindings : key => {
      bucket  = binding.bucket
      role    = binding.role
      members = binding.members
    }
  }
}

# ============================
# NOTIFICATION OUTPUTS
# ============================

output "bucket_notifications" {
  description = "Bucket notifications configuration"
  value = {
    for key, notification in google_storage_notification.bucket_notifications : key => {
      bucket         = notification.bucket
      payload_format = notification.payload_format
      topic          = notification.topic
      event_types    = notification.event_types
      notification_id = notification.notification_id
    }
  }
}

# ============================
# MODULE METADATA OUTPUTS
# ============================

output "module_metadata" {
  description = "Metadata about the module execution"
  value = {
    module_version              = "1.0.0"
    terraform_version          = "~> 1.0"
    google_provider_version    = "~> 4.5"
    google_beta_provider_version = "~> 4.5"
    buckets_created            = length(google_storage_bucket.primary_buckets) + (var.create_secondary_bucket ? 1 : 0)
    primary_buckets_count      = length(google_storage_bucket.primary_buckets)
    secondary_bucket_created   = var.create_secondary_bucket
    environment               = var.environment
    project_id                = var.project_id
    common_labels             = local.common_labels
  }
}