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

# ============================
# OPTIONAL VARIABLES
# ============================

variable "environment" {
  description = "Environment name (e.g., dev, staging, production)"
  type        = string
  default     = "production"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.environment))
    error_message = "Environment must be lowercase alphanumeric with hyphens."
  }
}

# ============================
# SERVICE ACCOUNT VARIABLES
# ============================

variable "web_service_account" {
  description = "Email of the web service account for bucket access"
  type        = string
  validation {
    condition     = var.web_service_account == null || can(regex("^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$", var.web_service_account))
    error_message = "Web service account must be a valid email address."
  }
}

variable "app_service_account" {
  description = "Email of the application service account for bucket access"
  type        = string
  validation {
    condition     = var.app_service_account == null || can(regex("^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$", var.app_service_account))
    error_message = "Application service account must be a valid email address."
  }
}

variable "analytics_service_account" {
  description = "Email of the analytics service account for bucket access"
  type        = string
  validation {
    condition     = var.analytics_service_account == null || can(regex("^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$", var.analytics_service_account))
    error_message = "Analytics service account must be a valid email address."
  }
}


# ============================
# Buckt Configs 
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
    logging_config  = optional(object({
      log_bucket        = string
      log_object_prefix = optional(string)
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



# ============================
# LIFECYCLE POLICY VARIABLES
# ============================

variable "default_lifecycle_age" {
  description = "Default age in days for lifecycle policy to delete old versions"
  type        = number
  default     = 90
  validation {
    condition     = var.default_lifecycle_age > 0
    error_message = "Default lifecycle age must be positive."
  }
}

variable "default_num_newer_versions" {
  description = "Number of newer versions to keep"
  type        = number
  default     = 3
  validation {
    condition     = var.default_num_newer_versions > 0
    error_message = "Number of newer versions must be positive."
  }
}

variable "nearline_age" {
  description = "Age in days to transition to NEARLINE storage class"
  type        = number
  default     = 30
  validation {
    condition     = var.nearline_age > 0
    error_message = "Nearline age must be positive."
  }
}

variable "coldline_age" {
  description = "Age in days to transition to COLDLINE storage class"
  type        = number
  default     = 90
  validation {
    condition     = var.coldline_age > 0
    error_message = "Coldline age must be positive."
  }
}

variable "archive_age" {
  description = "Age in days to transition to ARCHIVE storage class"
  type        = number
  default     = 365
  validation {
    condition     = var.archive_age > 0
    error_message = "Archive age must be positive."
  }
}



# ============================
# SECONDARY BUCKET VARIABLES
# ============================

variable "create_secondary_bucket" {
  description = "Whether to create a secondary bucket for backups"
  type        = bool
  default     = true
}

variable "secondary_bucket_name" {
  description = "Name of your second bucket"
  type        = string
}

variable "secondary_bucket_location" {
  description = "Location of the secondary backup bucket"
  type        = string
  default     = "US-EAST1"
}

variable "secondary_storage_class" {
  description = "Storage class for the secondary bucket"
  type        = string
  default     = "NEARLINE"
  validation {
    condition     = contains(["STANDARD", "NEARLINE", "COLDLINE", "ARCHIVE"], var.secondary_storage_class)
    error_message = "Storage class must be one of: STANDARD, NEARLINE, COLDLINE, ARCHIVE."
  }
}

variable "secondary_versioning_enabled" {
  description = "Versioning on 2nd bucket"
  type        = bool 
}

variable "secondary_public_access_prevention" {
  description = "Public access prevention for secondary bucket"
  type        = string
  default     = "enforced"
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

variable "secondary_bucket_labels" {
  description = "Labels for secondary bucket"
  type        = map(string)
  default     = {}
}

# ============================
# IAM GROUP VARIABLES
# ============================

variable "frontend_team_group" {
  description = "Google Group email for frontend team"
  type        = string
  default     = "frontend-team@yourdomain.com"
}

variable "backend_team_group" {
  description = "Google Group email for backend team"
  type        = string
  default     = "backend-team@yourdomain.com"
}

variable "data_team_group" {
  description = "Google Group email for data team"
  type        = string
  default     = "data-team@yourdomain.com"
}

# ============================
# FEATURE FLAGS
# ============================

variable "enable_versioning" {
  description = "Enable versioning for all buckets"
  type        = bool
  default     = true
}

variable "enable_uniform_bucket_level_access" {
  description = "Enable uniform bucket level access for all buckets"
  type        = bool
  default     = true
}

variable "enable_public_access_prevention" {
  description = "Enable public access prevention for all buckets"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Force destroy buckets even if not empty (use with caution in production)"
  type        = bool
  default     = false
}


# ============================
# CORS CONFIGURATION
# ============================

variable "cors_origins" {
  description = "List of allowed origins for CORS configuration"
  type        = list(string)
  default     = ["https://yourdomain.com", "https://www.yourdomain.com"]
}

variable "cors_methods" {
  description = "List of allowed HTTP methods for CORS"
  type        = list(string)
  default     = ["GET", "POST", "PUT"]
}

variable "cors_headers" {
  description = "List of allowed response headers for CORS"
  type        = list(string)
  default     = ["Content-Type", "Authorization"]
}

variable "cors_max_age" {
  description = "Maximum age in seconds for CORS preflight requests"
  type        = number
  default     = 3600
}


# ============================
# Logging
# ============================
variable "central_log_bucket" {
  description = "Central log bucket for logging"
  type        = string
  default = ""
}


# ============================
# labels
# ============================
variable "labels" {
  description = "Common labels to apply to all resources"
  type        = map(string)
  default     = {}
}


variable "bucket_iam_bindings" {
  description = "IAM bindings for buckets"
  type = list(object({
    bucket_name = string
    role        = string
    members     = list(string)
  }))
  default = []
}