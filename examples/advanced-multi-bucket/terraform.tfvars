
# ============================
# REQUIRED VARIABLES
# ============================

# Replace with your actual GCP project ID
project_id = "grounded-tine-460817-c0"

# GCP region for resources
region = "us-central1"


# bucket config
bucket_configs= [
    {
      name                         = "grounded-tine-460817-c0-web-assets-production"
      location                     = "US"
      storage_class               = "STANDARD"
      versioning_enabled          = true
      public_access_prevention    = "enforced"
      uniform_bucket_level_access = true
      force_destroy               = false
      labels =  {
        purpose = "web-assets"
        tier    = "frontend"
      }
      logging_config = {
        log_bucket = "+++++++++yout_central_loggin_bucket++++++++"
      }
    },
    {
      name                         = "grounded-tine-460817-c0-user-uploads-production"
      location                     = "US-CENTRAL1"
      storage_class               = "STANDARD"
      versioning_enabled          = true
      public_access_prevention    = "enforced"
      uniform_bucket_level_access = true
      force_destroy               = false
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
          origin          = ["https://yourdomain.com", "https://www.yourdomain.com"]
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
      force_destroy               = false
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
# ENVIRONMENT CONFIGURATION
# ===========================
environment  = "production"

# ============================
# CORS CONFIGURATION
# ============================
cors_origins = ["*"]
cors_methods = ["GET", "POST", "PUT"]
cors_headers = ["Content-Type", "Authorization"]
cors_max_age = 3600


# ============================
# SECONDARY BUCKET CONFIGURATION
# ============================
create_secondary_bucket     = true
secondary_bucket_name = "grounded-tine-460817-c0-backups-production"
secondary_bucket_location   = "US-EAST1"
secondary_storage_class     = "NEARLINE"
secondary_versioning_enabled = true
secondary_public_access_prevention = "enforced"
secondary_lifecycle_rules = [
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
  secondary_bucket_labels = {
    purpose = "backups"
    tier    = "disaster-recovery"
  }


# ============================
# IAM GROUP CONFIGURATION
# ============================
frontend_team_group = "frontend-team@yourdomain.com"
backend_team_group  = "backend-team@yourdomain.com"
data_team_group     = "data-team@yourdomain.com"


# ============================
# Bucket Bindings
# ============================
bucket_iam_bindings = [
  {
    bucket_name = "grounded-tine-460817-c0-web-assets-production"
    role        = "roles/storage.objectViewer"
    members = [
      "serviceAccount:web-service-account@grounded-tine-460817-c0.iam.gserviceaccount.com",
      "group:frontend-team@yourdomain.com"
    ]
  },
  {
    bucket_name = "grounded-tine-460817-c0-user-uploads-production"
    role        = "roles/storage.objectCreator"
    members = [
      "serviceAccount:app-service-account@grounded-tine-460817-c0.iam.gserviceaccount.com",
      "group:backend-team@yourdomain.com"
    ]
  },
  {
    bucket_name = "grounded-tine-460817-c0-data-lake-production"
    role        = "roles/storage.admin"
    members = [
      "serviceAccount:analytics-service-account@grounded-tine-460817-c0.iam.gserviceaccount.com",
      "group:data-team@yourdomain.com"
    ]
  }
]

