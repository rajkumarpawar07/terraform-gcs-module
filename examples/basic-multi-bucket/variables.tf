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
  }))
}

# ============================
# SECONDARY BUCKET CONFIGURATION
# ============================
variable "create_secondary_bucket" {
  description = "Create a secondary bucket"
  type        = bool
  default     = false
}

variable "secondary_bucket_name" {
  description = "Name of the secondary bucket"
  type        = string
}

variable "secondary_bucket_location" {
  description = "Location of the secondary bucket"
  type        = string
}

variable "secondary_storage_class" {
  description = "Storage class for the secondary bucket"
  type        = string
  default     = "STANDARD"
}

variable "secondary_public_access_prevention" {
  description = "Public access prevention for secondary bucket"
  type        = string
  default     = "enforced"
}

variable "secondary_uniform_bucket_level_access" {
  description = "Uniform bucket level access for secondary bucket"
  type        = bool
}

variable "secondary_force_destroy" {
  description = "Force destroy for secondary bucket"
  type        = bool
}

variable "secondary_versioning_enabled" {
  description = "Enable versioning for secondary bucket"
  type        = bool
}

variable "secondary_lifecycle_rules" {
  description = "Lifecycle rules for the secondary bucket"
  type        = list(any)
}

variable "secondary_bucket_labels" {
  description = "Additional labels for secondary bucket"
  type        = map(string)
  default     = {}
}

# ============================
# COMMON LABELS
# ============================
variable "common_labels" {
  description = "Common labels for all resources"
  type        = map(string)
}

