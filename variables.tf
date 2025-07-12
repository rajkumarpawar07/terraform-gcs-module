# variables.tf - GCS Module Variables
# Author: DevOps Team
# Version: 1.0.0
# Description: Variable definitions for GCS buckets module with versioning and lifecycle policies

# ============================
# REQUIRED VARIABLES
# ============================

variable "project_id" {
  description = "The GCP project ID where buckets will be created"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.project_id))
    error_message = "Project ID must be a valid GCP project ID format."
  }
}

variable "bucket_configs" {
  description = "List of bucket configurations with their properties"
  type = list(object({
    name                         = string
    location                     = string
    storage_class               = optional(string, "STANDARD")
    versioning_enabled          = optional(bool, true)
    public_access_prevention    = optional(string, "enforced")
    uniform_bucket_level_access = optional(bool, true)
    force_destroy               = optional(bool, true)
    labels                      = optional(map(string), {})
    lifecycle_rules            = optional(list(object({
      action = object({
        type          = string
        storage_class = optional(string)
      })
      condition = object({
        age                   = optional(number)
        created_before        = optional(string)
        with_state           = optional(string)
        matches_storage_class = optional(list(string))
        num_newer_versions   = optional(number)
        matches_prefix       = optional(list(string))
        matches_suffix       = optional(list(string))
      })
    })), null)
    kms_key_name    = optional(string)
    logging_config  = optional(object({
      log_bucket        = string
      log_object_prefix = optional(string)
    }))
    website_config = optional(object({
      main_page_suffix = string
      not_found_page   = optional(string)
    }))
    cors_config = optional(list(object({
      origin          = list(string)
      method          = list(string)
      response_header = list(string)
      max_age_seconds = number
    })))
    retention_policy = optional(object({
      is_locked        = bool
      retention_period = number
    }))
  }))

  validation {
    condition = length(var.bucket_configs) >= 1
    error_message = "At least one bucket configuration must be provided."
  }

  validation {
    condition = alltrue([
      for config in var.bucket_configs : 
      contains(["STANDARD", "NEARLINE", "COLDLINE", "ARCHIVE"], config.storage_class)
    ])
    error_message = "Storage class must be one of: STANDARD, NEARLINE, COLDLINE, ARCHIVE."
  }

  validation {
    condition = alltrue([
      for config in var.bucket_configs : 
      contains(["enforced", "inherited"], config.public_access_prevention)
    ])
    error_message = "Public access prevention must be either 'enforced' or 'inherited'."
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.environment))
    error_message = "Environment must be lowercase alphanumeric with hyphens."
  }
}

# ============================
# OPTIONAL VARIABLES
# ============================

variable "labels" {
  description = "Common labels to apply to all resources"
  type        = map(string)
  default     = {}
}

# ============================
# LIFECYCLE POLICY VARIABLES
# ============================

variable "default_lifecycle_age" {
  description = "Default age in days for lifecycle policy to delete old versions"
  type        = number
  default     = 1
  validation {
    condition     = var.default_lifecycle_age > 0
    error_message = "Default lifecycle age must be positive."
  }
}

variable "default_num_newer_versions" {
  description = "Number of newer versions to keep"
  type        = number
  default     = 2
  validation {
    condition     = var.default_num_newer_versions > 0
    error_message = "Number of newer versions must be positive."
  }
}

variable "nearline_age" {
  description = "Age in days to transition to NEARLINE storage class"
  type        = number
  default     = 2
  validation {
    condition     = var.nearline_age > 0
    error_message = "Nearline age must be positive."
  }
}

variable "coldline_age" {
  description = "Age in days to transition to COLDLINE storage class"
  type        = number
  default     = 3
  validation {
    condition     = var.coldline_age > 0
    error_message = "Coldline age must be positive."
  }
}

variable "archive_age" {
  description = "Age in days to transition to ARCHIVE storage class"
  type        = number
  default     = 4
  validation {
    condition     = var.archive_age > 0
    error_message = "Archive age must be positive."
  }
}

# ============================
# SECONDARY BUCKET VARIABLES
# ============================

variable "create_secondary_bucket" {
  description = "Whether to create a secondary bucket"
  type        = bool
  default     = false
}

variable "secondary_bucket_name" {
  description = "Name of the secondary bucket"
  type        = string
  default     = null
}

variable "secondary_bucket_location" {
  description = "Location of the secondary bucket"
  type        = string
  default     = "US"
}

variable "secondary_storage_class" {
  description = "Storage class for the secondary bucket"
  type        = string
  default     = "STANDARD"
  validation {
    condition     = contains(["STANDARD", "NEARLINE", "COLDLINE", "ARCHIVE"], var.secondary_storage_class)
    error_message = "Storage class must be one of: STANDARD, NEARLINE, COLDLINE, ARCHIVE."
  }
}

variable "secondary_public_access_prevention" {
  description = "Public access prevention for secondary bucket"
  type        = string
  default     = "enforced"
  validation {
    condition     = contains(["enforced", "inherited"], var.secondary_public_access_prevention)
    error_message = "Public access prevention must be either 'enforced' or 'inherited'."
  }
}

variable "secondary_uniform_bucket_level_access" {
  description = "Enable uniform bucket level access for secondary bucket"
  type        = bool
  default     = true
}

variable "secondary_force_destroy" {
  description = "Force destroy secondary bucket even if not empty"
  type        = bool
  default     = true
}

variable "secondary_versioning_enabled" {
  description = "Enable versioning for secondary bucket"
  type        = bool
  default     = true
}

variable "secondary_bucket_labels" {
  description = "Labels for secondary bucket"
  type        = map(string)
  default     = {}
}

variable "secondary_lifecycle_rules" {
  description = "Custom lifecycle rules for secondary bucket"
  type = list(object({
    action = object({
      type          = string
      storage_class = optional(string)
    })
    condition = object({
      age                   = optional(number)
      created_before        = optional(string)
      with_state           = optional(string)
      matches_storage_class = optional(list(string))
      num_newer_versions   = optional(number)
      matches_prefix       = optional(list(string))
      matches_suffix       = optional(list(string))
    })
  }))
  default = null
}

variable "secondary_kms_key_name" {
  description = "KMS key name for secondary bucket encryption"
  type        = string
  default     = null
}

# ============================
# IAM VARIABLES
# ============================

variable "bucket_iam_bindings" {
  description = "IAM bindings for buckets"
  type = list(object({
    bucket_name = string
    role        = string
    members     = list(string)
  }))
  default = []
}

# # ============================
# # NOTIFICATION VARIABLES
# # ============================

# variable "bucket_notifications" {
#   description = "Bucket notifications configuration"
#   type = map(object({
#     bucket_name         = string
#     payload_format      = string
#     topic              = string
#     event_types        = list(string)
#     object_name_prefix = optional(string)
#   }))
#   default = {}
# }

# ============================
# FEATURE FLAGS
# ============================

variable "enable_uniform_bucket_level_access" {
  description = "Enable uniform bucket level access by default"
  type        = bool
  default     = true
}

variable "enable_versioning_by_default" {
  description = "Enable versioning by default for all buckets"
  type        = bool
  default     = true
}

variable "enable_public_access_prevention" {
  description = "Enable public access prevention by default"
  type        = bool
  default     = true
}