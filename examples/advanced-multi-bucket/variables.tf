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
# Logging
# ============================
variable "central_log_bucket" {
  description = "Central log bucket for logging"
  type        = string
  default = ""
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
# CORS CONFIGURATION VARIABLE
# ============================

variable "cors_config" {
  description = "CORS configuration for buckets that need it"
  type = list(object({
    origin          = list(string)
    method          = list(string)
    response_header = list(string)
    max_age_seconds = number
  }))
  default = [
    {
      origin          = ["*"]
      method          = ["GET", "POST", "PUT"]
      response_header = ["Content-Type", "Authorization"]
      max_age_seconds = 3600
    }
  ]
}

# ============================
# SECONDARY BUCKET VARIABLES
# ============================
variable "create_secondary_bucket" {
  description = "Whether to create a secondary bucket for backups"
  type        = bool
  default     = true
}

