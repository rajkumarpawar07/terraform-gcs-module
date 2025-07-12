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

}






