# main.tf - GCS Buckets Module with Versioning and Lifecycle Policies
# Author: DevOps Team
# Version: 1.0.0
# Description: Reusable Terraform module for creating GCS buckets with versioning, lifecycle policies, and best practices

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.5"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.5"
    }
  }
}

# Local values for better code organization and reusability
locals {
  # Common labels for all resources
  common_labels = merge(
    var.labels,
    {
      module      = "terraform-gcs-module"
      managed_by  = "rajkumar"
      environment = var.environment
    }
  )

  # Bucket configurations with incremental values
  bucket_configs = {
    for idx, bucket in var.bucket_configs : bucket.name => merge(bucket, {
      index = idx
    })
  }

  # Default lifecycle rules for versioning
   default_lifecycle_rules  = tolist([
    {
      action = {
        type          = "Delete"
        # storage_class = null  # Include the optional field
      }
      condition = {
        age                   = var.default_lifecycle_age
        created_before        = null
        with_state           = "ARCHIVED"
        matches_storage_class = null
        num_newer_versions   = var.default_num_newer_versions
        matches_prefix       = null
        matches_suffix       = null
      }
    },
    {
      action = {
        type = "SetStorageClass"
        storage_class = "NEARLINE"
      }
      condition = {
        age                   = var.nearline_age
        created_before        = null
        with_state           = null
        matches_storage_class = null
        num_newer_versions   = null
        matches_prefix       = null
        matches_suffix       = null
      }
    },
    {
      action = {
        type = "SetStorageClass"
        storage_class = "COLDLINE"
      }
      condition = {
        age                   = var.coldline_age
        created_before        = null
        with_state           = null
        matches_storage_class = null
        num_newer_versions   = null
        matches_prefix       = null
        matches_suffix       = null
      }
    },
    {
      action = {
        type = "SetStorageClass"
        storage_class = "ARCHIVE"
      }
      condition = {
        age                   = var.archive_age
        created_before        = null
        with_state           = null
        matches_storage_class = null
        num_newer_versions   = null
        matches_prefix       = null
        matches_suffix       = null
      }
    }
  ])
}

# Primary bucket (mandatory) - using for_each for multiple buckets
resource "google_storage_bucket" "primary_buckets" {
  for_each = local.bucket_configs

  name                        = each.value.name
  location                    = each.value.location
  project                     = var.project_id
  storage_class              = each.value.storage_class
  public_access_prevention   = each.value.public_access_prevention
  uniform_bucket_level_access = each.value.uniform_bucket_level_access
  force_destroy              = each.value.force_destroy

  labels = merge(
    local.common_labels,
    each.value.labels,
    {
      bucket_type = "primary"
      bucket_index = each.value.index
    }
  )

  # Versioning configuration
  versioning {
    enabled = each.value.versioning_enabled
  }

  # Lifecycle management with incremental rules
  dynamic "lifecycle_rule" {
  for_each = each.value.lifecycle_rules != null ? each.value.lifecycle_rules : local.default_lifecycle_rules
  # for_each = local.default_lifecycle_rules
   content {
     action {
       type          = lifecycle_rule.value.action.type
       storage_class = try(lifecycle_rule.value.action.storage_class, null)
     }
     condition {
       age                   = try(lifecycle_rule.value.condition.age, null)
       created_before        = try(lifecycle_rule.value.condition.created_before, null)
       with_state           = try(lifecycle_rule.value.condition.with_state, null)
       matches_storage_class = try(lifecycle_rule.value.condition.matches_storage_class, null)
       num_newer_versions   = try(lifecycle_rule.value.condition.num_newer_versions, null)
       matches_prefix       = try(lifecycle_rule.value.condition.matches_prefix, null)
       matches_suffix       = try(lifecycle_rule.value.condition.matches_suffix, null)
     }
   }
  }

  # Encryption configuration
  dynamic "encryption" {
    for_each = each.value.kms_key_name != null ? [1] : []
    content {
      default_kms_key_name = each.value.kms_key_name
    }
  }

  # Logging configuration
  dynamic "logging" {
    for_each = each.value.logging_config != null ? [each.value.logging_config] : []
    content {
      log_bucket        = logging.value.log_bucket
      log_object_prefix = logging.value.log_object_prefix
    }
  }

  # Website configuration
  dynamic "website" {
    for_each = each.value.website_config != null ? [each.value.website_config] : []
    content {
      main_page_suffix = website.value.main_page_suffix
      not_found_page   = website.value.not_found_page
    }
  }

  # CORS configuration
  dynamic "cors" {
    for_each = each.value.cors_config != null ? each.value.cors_config : []
    content {
      origin          = cors.value.origin
      method          = cors.value.method
      response_header = cors.value.response_header
      max_age_seconds = cors.value.max_age_seconds
    }
  }

  # Retention policy
  dynamic "retention_policy" {
    for_each = each.value.retention_policy != null ? [each.value.retention_policy] : []
    content {
      is_locked        = retention_policy.value.is_locked
      retention_period = retention_policy.value.retention_period
    }
  }
}

# Optional secondary bucket with different configuration
resource "google_storage_bucket" "secondary_bucket" {
  count = var.create_secondary_bucket ? 1 : 0

  name                        = var.secondary_bucket_name
  location                    = var.secondary_bucket_location
  project                     = var.project_id
  storage_class              = var.secondary_storage_class
  public_access_prevention   = var.secondary_public_access_prevention
  uniform_bucket_level_access = var.secondary_uniform_bucket_level_access
  force_destroy              = var.secondary_force_destroy

  labels = merge(
    local.common_labels,
    var.secondary_bucket_labels,
    {
      bucket_type = "secondary"
      bucket_index = "secondary"
    }
  )

  # Versioning for secondary bucket
  versioning {
    enabled = var.secondary_versioning_enabled
  }

  # Lifecycle rules for secondary bucket
  dynamic "lifecycle_rule" {
    for_each = var.secondary_lifecycle_rules != null ? var.secondary_lifecycle_rules : local.default_lifecycle_rules
    # for_each = local.default_lifecycle_rules
    content {
      action {
        type          = lifecycle_rule.value.action.type
        storage_class = try(lifecycle_rule.value.action.storage_class, null)
      }
      condition {
        age                   = try(lifecycle_rule.value.condition.age, null)
        created_before        = try(lifecycle_rule.value.condition.created_before, null)
        with_state           = try(lifecycle_rule.value.condition.with_state, null)
        matches_storage_class = try(lifecycle_rule.value.condition.matches_storage_class, null)
        num_newer_versions   = try(lifecycle_rule.value.condition.num_newer_versions, null)
        matches_prefix       = try(lifecycle_rule.value.condition.matches_prefix, null)
        matches_suffix       = try(lifecycle_rule.value.condition.matches_suffix, null)
      }
    }
  }

  # Encryption for secondary bucket
  dynamic "encryption" {
    for_each = var.secondary_kms_key_name != null ? [1] : []
    content {
      default_kms_key_name = var.secondary_kms_key_name
    }
  }
}

# IAM bindings for buckets (best practice for access control)
resource "google_storage_bucket_iam_binding" "bucket_iam_bindings" {
  for_each = {
    for binding in var.bucket_iam_bindings : "${binding.bucket_name}-${binding.role}" => binding
  }

  bucket = each.value.bucket_name
  role   = each.value.role
  members = each.value.members

  depends_on = [
    google_storage_bucket.primary_buckets,
    google_storage_bucket.secondary_bucket
  ]
}


