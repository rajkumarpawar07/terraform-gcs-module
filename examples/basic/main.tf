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
        age = 30
        matches_prefix = ["media/", "uploads/"]
      }
    },
    {
      action = {
        type          = "SetStorageClass"
        storage_class = "COLDLINE"
      }
      condition = {
        age = 90
        matches_prefix = ["backups/", "archives/"]
      }
    },
    {
      action = {
        type = "Delete"
      }
      condition = {
        age = 2555 # 7 years
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
        age                = 365
        num_newer_versions = 5
      }
    },
    {
      action = {
        type          = "SetStorageClass"
        storage_class = "ARCHIVE"
      }
      condition = {
        age = 180
      }
    }
  ]
}

# ============================
# EXAMPLE 1: Basic Multi-Bucket Setup
# ============================

module "gcs_basic_setup" {
  source = "git::https://github.com/your-org/terraform-gcp-gcs-module.git?ref=v1.0.0"
  
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
      force_destroy               = false
      labels = merge(local.common_labels, {
        purpose = "web-assets"
        tier    = "frontend"
      })
    },
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
          origin          = ["https://yourdomain.com", "https://www.yourdomain.com"]
          method          = ["GET", "POST", "PUT"]
          response_header = ["Content-Type", "Authorization"]
          max_age_seconds = 3600
        }
      ]
    },
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
  secondary_force_destroy               = false
  secondary_lifecycle_rules             = local.backup_lifecycle_rules
  secondary_bucket_labels = merge(local.common_labels, {
    purpose = "backups"
    tier    = "disaster-recovery"
  })
  
  # Common labels
  labels = local.common_labels
  
  # Lifecycle policy customization
  default_lifecycle_age        = 90
  default_num_newer_versions   = 3
  nearline_age                = 30
  coldline_age                = 90
  archive_age                 = 365
  
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

# # ============================
# # EXAMPLE 2: High-Security Setup with Encryption
# # ============================

# module "gcs_secure_setup" {
#   source = "git::https://github.com/your-org/terraform-gcp-gcs-module.git?ref=v1.0.0"
  
#   project_id  = var.project_id
#   environment = "${local.environment}-secure"
  
#   bucket_configs = [
#     {
#       name                         = "${var.project_id}-sensitive-data-${local.environment}"
#       location                     = "US-CENTRAL1"
#       storage_class               = "STANDARD"
#       versioning_enabled          = true
#       public_access_prevention    = "enforced"
#       uniform_bucket_level_access = true
#       force_destroy               = false
#       kms_key_name                = var.kms_key_name
#       labels = merge(local.common_labels, {
#         purpose     = "sensitive-data"
#         tier        = "security"
#         encryption  = "customer-managed"
#       })
#       retention_policy = {
#         is_locked        = true
#         retention_period = 2592000 # 30 days
#       }
#     }
#   ]
  
#   # Enhanced lifecycle policies for security
#   default_lifecycle_age        = 60
#   default_num_newer_versions   = 5
#   nearline_age                = 15
#   coldline_age                = 60
#   archive_age                 = 180
  
#   labels = merge(local.common_labels, {
#     security_level = "high"
#     compliance     = "required"
#   })
# }

# # ============================
# # EXAMPLE 3: Development Environment with Relaxed Policies
# # ============================

# module "gcs_dev_setup" {
#   source = "git::https://github.com/your-org/terraform-gcp-gcs-module.git?ref=v1.0.0"
  
#   project_id  = var.dev_project_id
#   environment = "development"
  
#   bucket_configs = [
#     {
#       name                         = "${var.dev_project_id}-dev-testing-${random_string.dev_suffix.result}"
#       location                     = "US-CENTRAL1"
#       storage_class               = "STANDARD"
#       versioning_enabled          = true
#       public_access_prevention    = "enforced"
#       uniform_bucket_level_access = true
#       force_destroy               = true # Allow destruction in dev
#       labels = merge(local.common_labels, {
#         purpose     = "development"
#         tier        = "testing"
#         auto_delete = "enabled"
#       })
#     }
#   ]
  
#   # More aggressive cleanup for dev environment
#   default_lifecycle_age        = 7
#   default_num_newer_versions   = 2
#   nearline_age                = 1
#   coldline_age                = 3
#   archive_age                 = 7
  
#   labels = merge(local.common_labels, {
#     environment = "development"
#     auto_cleanup = "aggressive"
#   })
# }

# # ============================
# # EXAMPLE 4: Website Hosting Setup
# # ============================

# module "gcs_website_setup" {
#   source = "git::https://github.com/your-org/terraform-gcp-gcs-module.git?ref=v1.0.0"
  
#   project_id  = var.project_id
#   environment = "${local.environment}-website"
  
#   bucket_configs = [
#     {
#       name                         = "www.yourdomain.com"
#       location                     = "US"
#       storage_class               = "STANDARD"
#       versioning_enabled          = true
#       public_access_prevention    = "inherited" # Allow public access for website
#       uniform_bucket_level_access = false
#       force_destroy               = false
#       labels = merge(local.common_labels, {
#         purpose = "website-hosting"
#         tier    = "frontend"
#         public  = "true"
#       })
#       website_config = {
#         main_page_suffix = "index.html"
#         not_found_page   = "404.html"
#       }
#     }
#   ]
  
#   # Website-optimized lifecycle policies
#   default_lifecycle_age        = 30
#   default_num_newer_versions   = 10
#   nearline_age                = 7
#   coldline_age                = 30
#   archive_age                 = 90
  
#   labels = merge(local.common_labels, {
#     purpose = "website"
#     public_access = "enabled"
#   })
# }

# # ============================
# # SUPPORTING RESOURCES
# # ============================

# # Random string for unique naming in dev
# resource "random_string" "dev_suffix" {
#   length  = 8
#   special = false
#   upper   = false
# }

# # KMS key for encryption (referenced in secure setup)
# resource "google_kms_key_ring" "bucket_keyring" {
#   name     = "${var.project_id}-bucket-keyring"
#   location = "us-central1"
# }

# resource "google_kms_crypto_key" "bucket_key" {
#   name            = "bucket-encryption-key"
#   key_ring        = google_kms_key_ring.bucket_keyring.id
#   rotation_period = "7776000s" # 90 days
  
#   labels = local.common_labels
# }

# # Service accounts for different services
# resource "google_service_account" "web_service_account" {
#   account_id   = "web-service-${local.environment}"
#   display_name = "Web Service Account"
#   description  = "Service account for web application"
# }

# resource "google_service_account" "app_service_account" {
#   account_id   = "app-service-${local.environment}"
#   display_name = "Application Service Account"
#   description  = "Service account for backend application"
# }

# resource "google_service_account" "analytics_service_account" {
#   account_id   = "analytics-service-${local.environment}"
#   display_name = "Analytics Service Account"
#   description  = "Service account for analytics workloads"
# }

# # ============================
# # OUTPUTS FROM MODULE USAGE
# # ============================

# output "basic_setup_buckets" {
#   description = "Basic setup bucket details"
#   value       = module.gcs_basic_setup.primary_buckets_details
# }

# output "secure_setup_buckets" {
#   description = "Secure setup bucket details"
#   value       = module.gcs_secure_setup.primary_buckets_details
# }

# output "dev_setup_buckets" {
#   description = "Development setup bucket details"
#   value       = module.gcs_dev_setup.primary_buckets_details
# }

# output "website_setup_buckets" {
#   description = "Website setup bucket details"
#   value       = module.gcs_website_setup.primary_buckets_details
# }

# output "all_bucket_names" {
#   description = "All bucket names created across all module instances"
#   value = concat(
#     module.gcs_basic_setup.all_bucket_names,
#     module.gcs_secure_setup.all_bucket_names,
#     module.gcs_dev_setup.all_bucket_names,
#     module.gcs_website_setup.all_bucket_names
#   )
# }

# output "versioning_summary" {
#   description = "Summary of versioning status across all buckets"
#   value = {
#     basic_setup   = module.gcs_basic_setup.versioning_status
#     secure_setup  = module.gcs_secure_setup.versioning_status
#     dev_setup     = module.gcs_dev_setup.versioning_status
#     website_setup = module.gcs_website_setup.versioning_status
#   }
# }

# output "service_accounts" {
#   description = "Service accounts created for bucket access"
#   value = {
#     web_service_account       = google_service_account.web_service_account.email
#     app_service_account       = google_service_account.app_service_account.email
#     analytics_service_account = google_service_account.analytics_service_account.email
#   }
# }

# output "kms_key_name" {
#   description = "KMS key name for bucket encryption"
#   value       = google_kms_crypto_key.bucket_key.id
# }