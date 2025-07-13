terraform {
  required_version = ">= 1.0"
}

provider "google" {
  project = var.project_id
  region  = var.region
}


# Local values for better organization
locals {
  environment = var.environment
  region      = var.region
  
  # Common labels for all resources
  common_labels = {
    environment   = local.environment
    project       = "my-web-app"
    team          = "platform-engineering"
    created_by    = "rajkumar"
  }

  # Custom lifecycle rules for specific use cases
  media_lifecycle_rules = [
    {
      action = {
        type          = "SetStorageClass"
        storage_class = "NEARLINE"
      }
      condition = {
        age = 1
        matches_prefix = ["media/", "uploads/"]
      }
    },
    {
      action = {
        type          = "SetStorageClass"
        storage_class = "COLDLINE"
      }
      condition = {
        age = 2
        matches_prefix = ["backups/", "archives/"]
      }
    },
    {
      action = {
        type = "Delete"
      }
      condition = {
        age = 3 # 7 years
        matches_prefix = ["temp/", "cache/"]
      }
    }
  ]

  # Backup lifecycle rules - more aggressive cleanup
  backup_lifecycle_rules = [
    {
      action = {
        type = "Delete"
      }
      condition = {
        age                = 1
        num_newer_versions = 2
      }
    },
    {
      action = {
        type          = "SetStorageClass"
        storage_class = "ARCHIVE"
      }
      condition = {
        age = 2
      }
    }
  ]
}

module "gcs_basic_setup" {
  source = "git::https://github.com/rajkumarpawar07/terraform-gcs-module.git?ref=v2.0.0"
  
  # Required variables
  project_id  = var.project_id
  environment = local.environment
  
  # Bucket configurations with incremental features
  bucket_configs = [
    {
      name                         = "${var.project_id}-web-assets-${local.environment}"
      location                     = "US"
      storage_class               = "STANDARD"
      versioning_enabled          = true
      public_access_prevention    = "enforced"
      uniform_bucket_level_access = true
      force_destroy               = true
      labels = merge(local.common_labels, {
        purpose = "web-assets"
        tier    = "frontend"
      })
      logging_config = {
        log_bucket = var.central_log_bucket
      }
    },
    {
      name                         = "${var.project_id}-user-uploads-${local.environment}"
      location                     = "US-CENTRAL1"
      storage_class               = "STANDARD"
      versioning_enabled          = true
      public_access_prevention    = "enforced"
      uniform_bucket_level_access = true
      force_destroy               = true
      lifecycle_rules             = local.media_lifecycle_rules
      labels = merge(local.common_labels, {
        purpose = "user-uploads"
        tier    = "application"
      })
      cors_config =var.cors_config
    },
    {
      name                         = "${var.project_id}-data-lake-${local.environment}"
      location                     = "US-CENTRAL1"
      storage_class               = "COLDLINE"
      versioning_enabled          = true
      public_access_prevention    = "enforced"
      uniform_bucket_level_access = true
      force_destroy               = true
      labels = merge(local.common_labels, {
        purpose = "data-lake"
        tier    = "analytics"
      })
    }
  ]
  
  # Optional secondary bucket for backups
  create_secondary_bucket                = var.create_secondary_bucket
  secondary_bucket_name                  = "${var.project_id}-backups-${local.environment}"
  secondary_bucket_location              = "US-EAST1"
  secondary_storage_class               = "NEARLINE"
  secondary_versioning_enabled          = true
  secondary_public_access_prevention    = "enforced"
  secondary_uniform_bucket_level_access = true
  secondary_force_destroy               = true
  secondary_lifecycle_rules             = local.backup_lifecycle_rules
  secondary_bucket_labels = merge(local.common_labels, {
    purpose = "backups"
    tier    = "disaster-recovery"
  })
  
  # Common labels
  labels = local.common_labels
  
  
  # IAM bindings for bucket access
  bucket_iam_bindings = [
    {
      bucket_name = "${var.project_id}-web-assets-${local.environment}"
      role        = "roles/storage.objectViewer"
      members = [
        "serviceAccount:${var.web_service_account}",
      ]
    },
    {
      bucket_name = "${var.project_id}-user-uploads-${local.environment}"
      role        = "roles/storage.objectCreator"
      members = [
        "serviceAccount:${var.app_service_account}",
      ]
    },
    {
      bucket_name = "${var.project_id}-data-lake-${local.environment}"
      role        = "roles/storage.admin"
      members = [
        "serviceAccount:${var.analytics_service_account}",
      ]
    }
  ]
}