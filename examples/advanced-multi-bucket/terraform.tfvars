
# ============================
# REQUIRED VARIABLES
# ============================

# Replace with your actual GCP project ID
project_id = "grounded-tine-460817-c0"

# GCP region for resources
region = "us-central1"

# ============================
# ENVIRONMENT CONFIGURATION
# ===========================
environment  = "production"


# ============================
# ########Logging#########
# ============================
central_log_bucket = "central_log_bucket_name"


    {
      name                         = "grounded-tine-460817-c0-web-assets-production"
      location                     = "US"
      storage_class               = "STANDARD"
      versioning_enabled          = true
      public_access_prevention    = "enforced"
      uniform_bucket_level_access = true
      force_destroy               = true
      labels =  {
        purpose = "web-assets"
        tier    = "frontend"
      }
      logging_config = {
        log_bucket = "grounded-tine-460817-c0-central-loggin-bucket"
      }
    },
    {
      name                         = "grounded-tine-460817-c0-user-uploads-production"
      location                     = "US-CENTRAL1"
      storage_class               = "STANDARD"
      versioning_enabled          = true
      public_access_prevention    = "enforced"
      uniform_bucket_level_access = true
      force_destroy               = true
      lifecycle_rules             = [
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
        age = 3 # 3 years
        matches_prefix = ["temp/", "cache/"]
      }
    }
  ]
      labels =  {
        purpose = "user-uploads"
        tier    = "application"
      }
      cors_config = [
        {
          origin          = ["*"]
          method          = ["GET", "POST", "PUT"]
          response_header = ["Content-Type", "Authorization"]
          max_age_seconds = 3600
        }
      ]
    },
    {
      name                         = "grounded-tine-460817-c0-data-lake-production"
      location                     = "US-CENTRAL1"
      storage_class               = "COLDLINE"
      versioning_enabled          = true
      public_access_prevention    = "enforced"
      uniform_bucket_level_access = true
      force_destroy               = true
      labels =  {
        purpose = "data-lake"
        tier    = "analytics"
      }
       retention_policy = {
        is_locked = true
        retention_period = 60    # 60 Secs
      }
     
    }
  ]



# ============================
# SERVICE ACCOUNT VARIABLES
# ============================
web_service_account       = "web-service-account@grounded-tine-460817-c0.iam.gserviceaccount.com"
app_service_account       = "app-service-account@grounded-tine-460817-c0.iam.gserviceaccount.com"
analytics_service_account = "analytics-service-account@grounded-tine-460817-c0.iam.gserviceaccount.com"


# ============================
# SECONDARY BUCKET CONFIGURATION
# ============================
create_secondary_bucket     = true
