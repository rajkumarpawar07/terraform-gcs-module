# variables.tf for Example Usage
# File: examples/basic/variables.tf
# Author: DevOps Team
# Version: 1.0.0
# Description: Variables for the example implementation of the GCS module

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

variable "dev_project_id" {
  description = "The GCP project ID for development environment"
  type        = string
  default     = null
  validation {
    condition     = var.dev_project_id == null || can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.dev_project_id))
    error_message = "Development project ID must be a valid GCP project ID format."
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

# ============================
# ENCRYPTION VARIABLES
# ============================

variable "kms_key_name" {
  description = "KMS key name for bucket encryption (optional)"
  type        = string
  default     = null
}

variable "enable_kms_encryption" {
  description = "Enable KMS encryption for buckets"
  type        = bool
  default     = false
}

# ============================
# ENVIRONMENT CONFIGURATION
# ============================

variable "environment_config" {
  description = "Environment-specific configuration"
  type = object({
    name                    = string
    enable_aggressive_cleanup = bool
    enable_public_access    = bool
    versioning_retention_days = number
    force_destroy           = bool
  })
  default = {
    name                    = "production"
    enable_aggressive_cleanup = false
    enable_public_access    = false
    versioning_retention_days = 90
    force_destroy           = false
  }
}

# ============================
# LIFECYCLE POLICY VARIABLES
# ============================

variable "custom_lifecycle_policies" {
  description = "Custom lifecycle policies for different bucket types"
  type = map(list(object({
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
  })))
  default = {}
}

# ============================
# BUCKET NAMING VARIABLES
# ============================

variable "bucket_naming_config" {
  description = "Configuration for bucket naming conventions"
  type = object({
    prefix              = optional(string, "")
    suffix              = optional(string, "")
    include_environment = optional(bool, true)
    include_project_id  = optional(bool, true)
    separator          = optional(string, "-")
  })
  default = {
    prefix              = ""
    suffix              = ""
    include_environment = true
    include_project_id  = true
    separator          = "-"
  }
}

# ============================
# WEBSITE CONFIGURATION
# ============================

variable "website_config" {
  description = "Website configuration for static site hosting"
  type = object({
    enable_website_hosting = bool
    domain_name           = optional(string)
    index_page           = optional(string, "index.html")
    error_page           = optional(string, "404.html")
    cors_origins         = optional(list(string), [])
  })
  default = {
    enable_website_hosting = false
    domain_name           = null
    index_page           = "index.html"
    error_page           = "404.html"
    cors_origins         = []
  }
}

# ============================
# NOTIFICATION VARIABLES
# ============================

variable "notification_config" {
  description = "Configuration for bucket notifications"
  type = object({
    enable_notifications = bool
    pubsub_topic        = optional(string)
    event_types         = optional(list(string), ["OBJECT_FINALIZE"])
    payload_format      = optional(string, "JSON_API_V1")
  })
  default = {
    enable_notifications = false
    pubsub_topic        = null
    event_types         = ["OBJECT_FINALIZE"]
    payload_format      = "JSON_API_V1"
  }
}

# ============================
# SECURITY VARIABLES
# ============================

variable "security_config" {
  description = "Security configuration for buckets"
  type = object({
    enable_uniform_bucket_level_access = bool
    enable_public_access_prevention   = bool
    enable_bucket_policy_only         = bool
    enable_retention_policy          = bool
    retention_period_days            = optional(number, 30)
    enable_object_versioning         = bool
    max_versions_to_keep            = optional(number, 10)
  })
  default = {
    enable_uniform_bucket_level_access = true
    enable_public_access_prevention   = true
    enable_bucket_policy_only         = true
    enable_retention_policy          = false
    retention_period_days            = 30
    enable_object_versioning         = true
    max_versions_to_keep            = 10
  }
}

# ============================
# COST OPTIMIZATION VARIABLES
# ============================

variable "cost_optimization_config" {
  description = "Cost optimization configuration"
  type = object({
    enable_nearline_transition     = bool
    nearline_transition_days       = optional(number, 30)
    enable_coldline_transition     = bool
    coldline_transition_days       = optional(number, 90)
    enable_archive_transition      = bool
    archive_transition_days        = optional(number, 365)
    enable_deletion_policy         = bool
    deletion_age_days             = optional(number, 2555) # 7 years
  })
  default = {
    enable_nearline_transition     = true
    nearline_transition_days       = 30
    enable_coldline_transition     = true
    coldline_transition_days       = 90
    enable_archive_transition      = true
    archive_transition_days        = 365
    enable_deletion_policy         = false
    deletion_age_days             = 2555
  }
}

# ============================
# MONITORING VARIABLES
# ============================

variable "monitoring_config" {
  description = "Monitoring and logging configuration"
  type = object({
    enable_access_logs    = bool
    access_logs_bucket    = optional(string)
    access_logs_prefix    = optional(string, "access-logs/")
    enable_metrics        = bool
    metrics_export_bucket = optional(string)
  })
  default = {
    enable_access_logs    = false
    access_logs_bucket    = null
    access_logs_prefix    = "access-logs/"
    enable_metrics        = false
    metrics_export_bucket = null
  }
}

# ============================
# FEATURE FLAGS
# ============================

variable "feature_flags" {
  description = "Feature flags for enabling/disabling module features"
  type = object({
    enable_secondary_bucket     = bool
    enable_cross_region_replication = bool
    enable_object_lock         = bool
    enable_event_notifications = bool
    enable_audit_logs          = bool
    enable_data_classification = bool
  })
  default = {
    enable_secondary_bucket     = false
    enable_cross_region_replication = false
    enable_object_lock         = false
    enable_event_notifications = false
    enable_audit_logs          = true
    enable_data_classification = false
  }
}

# ============================
# TAGS AND LABELS
# ============================

variable "additional_labels" {
  description = "Additional labels to apply to all resources"
  type        = map(string)
  default     = {}
  validation {
    condition = alltrue([
      for k, v in var.additional_labels : can(regex("^[a-z][a-z0-9_-]*[a-z0-9]$", k))
    ])
    error_message = "Label keys must be lowercase alphanumeric with underscores and hyphens."
  }
}

# ============================
# COMPLIANCE VARIABLES
# ============================

variable "compliance_config" {
  description = "Compliance and regulatory configuration"
  type = object({
    enable_hipaa_compliance     = bool
    enable_sox_compliance       = bool
    enable_gdpr_compliance      = bool
    enable_pci_dss_compliance   = bool
    data_residency_requirements = optional(list(string), [])
    audit_log_retention_days    = optional(number, 365)
  })
  default = {
    enable_hipaa_compliance     = false
    enable_sox_compliance       = false
    enable_gdpr_compliance      = false
    enable_pci_dss_compliance   = false
    data_residency_requirements = []
    audit_log_retention_days    = 365
  }
}

# ============================
# BACKUP AND DISASTER RECOVERY
# ============================

variable "backup_config" {
  description = "Backup and disaster recovery configuration"
  type = object({
    enable_cross_region_backup = bool
    backup_region             = optional(string)
    backup_schedule           = optional(string, "daily")
    backup_retention_days     = optional(number, 30)
    enable_point_in_time_recovery = bool
  })
  default = {
    enable_cross_region_backup = false
    backup_region             = null
    backup_schedule           = "daily"
    backup_retention_days     = 30
    enable_point_in_time_recovery = false
  }
}