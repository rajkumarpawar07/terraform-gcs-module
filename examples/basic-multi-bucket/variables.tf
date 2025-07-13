# ============================
# REQUIRED VARIABLES
# ============================

variable "project_id" {
  description = "The GCP project ID where resources will be created"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.project_id))
    error_message = "Project ID must be a valid GCP project ID format."
  }
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
  default     = "us-central1"
  validation {
    condition = contains([
      "us-central1", "us-east1", "us-west1", "us-west2", "us-west3", "us-west4",
      "europe-west1", "europe-west2", "europe-west3", "europe-west4", "europe-west6",
      "europe-north1", "asia-east1", "asia-northeast1", "asia-southeast1",
      "asia-south1", "australia-southeast1", "southamerica-east1"
    ], var.region)
    error_message = "Region must be a valid GCP region."
  }
}

variable "environment" {
  description = "Environment name like dev/test/prod"
  type        = string
}

# ============================
# PRIMARY BUCKET CONFIGURATION
# ============================
variable "bucket_configs" {
  description = "List of bucket configurations"
  type        = list(any)
}


# ============================
# SECONDARY BUCKET CONFIGURATION
# ============================
variable "create_secondary_bucket" {
  description = "Create a secondary bucket"
  type        = bool
}

variable "secondary_bucket_config" {
  description = "Secondary bucket configuration"
  type        = any
}

variable "secondary_lifecycle_rules" {
  description = "Lifecycle rules for the secondary bucket"
  type        = list(any)
}

# ============================
# COMMON LABELS
# ============================
variable "common_labels" {
  description = "Common labels for all resources"
  type        = map(string)
}

# ============================
# SERVICE ACCOUNT VARIABLES
# ============================

variable "web_service_account" {
  description = "Email of the web service account for bucket access"
  type        = string
  default     = null
  validation {
    condition     = var.web_service_account == null || can(regex("^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$", var.web_service_account))
    error_message = "Web service account must be a valid email address."
  }
}

variable "app_service_account" {
  description = "Email of the application service account for bucket access"
  type        = string
  default     = null
  validation {
    condition     = var.app_service_account == null || can(regex("^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$", var.app_service_account))
    error_message = "Application service account must be a valid email address."
  }
}

variable "analytics_service_account" {
  description = "Email of the analytics service account for bucket access"
  type        = string
  default     = null
  validation {
    condition     = var.analytics_service_account == null || can(regex("^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$", var.analytics_service_account))
    error_message = "Analytics service account must be a valid email address."
  }
}