# Example Usage - How to Use the GCS Module in Another Project
# File: examples/basic/main.tf
# Author: DevOps Team
# Version: 1.0.0
# Description: Example implementation of the GCS module with best practices

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

# Configure the Google Cloud Provider
provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# Local values for better organization
locals {
  environment = "production"
  region      = "us-central1"
  
  # Common labels for all resources
  common_labels = {
    environment   = local.environment
    project       = "my-web-app"
    team          = "platform-engineering"
    cost_center   = "engineering"
    managed_by    = "terraform"
    created_by    = "devops-team"
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
        age = 3 # 2 days
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

# ============================
# EXAMPLE : Basic Multi-Bucket Setup
# ============================

module "gcs_basic_multi_setup" {
  source = "git::https://github.com/your-org/terraform-gcp-gcs-module.git"
  
  # Required variables
  project_id  = var.project_id
  environment = local.environment
  
  # Bucket configurations with incremental features
  bucket_configs = [
        # Bucket 1 = Web Assets Bucket for frontend resources
    {
      name                         = "${var.project_id}-web-assets-${local.environment}"
      location                     = "US"
      storage_class               = "STANDARD"
      versioning_enabled          = true
      public_access_prevention    = "enforced"
      uniform_bucket_level_access = true
      force_destroy               = false
      labels = merge(local.common_labels, {
        purpose = "web-assets"
        tier    = "frontend"
      })
    },
    # Bucket 2 = User Uploads Bucket for application data
    {
      name                         = "${var.project_id}-user-uploads-${local.environment}"
      location                     = "US-CENTRAL1"
      storage_class               = "STANDARD"
      versioning_enabled          = true
      public_access_prevention    = "enforced"
      uniform_bucket_level_access = true
      force_destroy               = false
      lifecycle_rules             = local.media_lifecycle_rules
      labels = merge(local.common_labels, {
        purpose = "user-uploads"
        tier    = "application"
      })
      cors_config = [
        {
          origin          = ["*"]
          method          = ["GET", "POST", "PUT"]
          response_header = ["Content-Type", "Authorization"]
          max_age_seconds = 3600
        }
      ]
    },
    # Bucket 3 = Data Lake Bucket  for Long-term analytics data storage
    {
      name                         = "${var.project_id}-data-lake-${local.environment}"
      location                     = "US-CENTRAL1"
      storage_class               = "COLDLINE"
      versioning_enabled          = true
      public_access_prevention    = "enforced"
      uniform_bucket_level_access = true
      force_destroy               = false
      labels = merge(local.common_labels, {
        purpose = "data-lake"
        tier    = "analytics"
      })
    }
  ]
  
  # Optional secondary bucket for backups
  create_secondary_bucket                = true
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
  
  # Lifecycle policy customization
  default_lifecycle_age        = 1
  default_num_newer_versions   = 2
  nearline_age                = 2
  coldline_age                = 3
  archive_age                 = 4
  
  # IAM bindings for bucket access
  bucket_iam_bindings = [
    {
      bucket_name = "${var.project_id}-web-assets-${local.environment}"
      role        = "roles/storage.objectViewer"
      members = [
        "serviceAccount:${var.web_service_account}",
        "group:frontend-team@yourdomain.com"
      ]
    },
    {
      bucket_name = "${var.project_id}-user-uploads-${local.environment}"
      role        = "roles/storage.objectCreator"
      members = [
        "serviceAccount:${var.app_service_account}",
        "group:backend-team@yourdomain.com"
      ]
    },
    {
      bucket_name = "${var.project_id}-data-lake-${local.environment}"
      role        = "roles/storage.admin"
      members = [
        "serviceAccount:${var.analytics_service_account}",
        "group:data-team@yourdomain.com"
      ]
    }
  ]
}