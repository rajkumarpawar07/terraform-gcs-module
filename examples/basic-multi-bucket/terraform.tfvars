project_id  = "grounded-tine-460817-c0"
region      = "us-central1"
environment = "production"

# ============================
# PRIMARY BUCKET CONFIGURATION
# ============================
bucket_configs = [
    {
      name                         = "grounded-tine-460817-c0-web-assets-prod"
      location                     = "US"
      storage_class               = "STANDARD"
      versioning_enabled          = true
      public_access_prevention    = "enforced"
      uniform_bucket_level_access = true
      labels = {
        purpose = "web-assets"
        tier    = "frontend"
      }
      lifecycle_rules = [
        {
      action = {
        type          = "Delete"
        storage_class = null  
      }
      condition = {
        age                   = 1
        created_before        = null
        with_state           = "ARCHIVED"
        matches_storage_class = null
        num_newer_versions   = 3
        matches_prefix       = null
        matches_suffix       = null
      }
    },
    {
      action = {
        type = "SetStorageClass"
        storage_class = "NEARLINE"
      }
      condition = {
        age                   = 2
        created_before        = null
        with_state           = null
        matches_storage_class = null
        num_newer_versions   = null
        matches_prefix       = null
        matches_suffix       = null
      }
    },

  ]
    },
    {
      name                         = "grounded-tine-460817-c0-user-uploads-prod"
      location                     = "US-CENTRAL1"
      storage_class               = "STANDARD"
      versioning_enabled          = true
      public_access_prevention    = "enforced"
      uniform_bucket_level_access = true
      labels = {
        purpose = "user-uploads"
        tier    = "application"
      },
    }
  ]



# ============================
# SECONDARY BUCKET CONFIGURATION
# ============================
create_secondary_bucket = true
secondary_bucket_name   = "grounded-tine-460817-c0-prod"
secondary_bucket_location = "EUROPE-WEST1"
secondary_storage_class = "COLDLINE"
secondary_versioning_enabled = true
secondary_public_access_prevention = "enforced"
secondary_uniform_bucket_level_access = true
secondary_force_destroy = false

secondary_bucket_labels = {
  purpose = "backup"
  tier    = "disaster-recovery"
}

# Optional custom lifecycle rules (optional, else defaults will be used)
secondary_lifecycle_rules = [
  {
    action = {
      type          = "SetStorageClass"
      storage_class = "ARCHIVE"
    }
    condition = {
      age                   = 3
      created_before        = null
      with_state           = null
      matches_storage_class = null
      num_newer_versions   = null
      matches_prefix       = null
      matches_suffix       = null
    }
  }
]

# ============================
# COMMON LABELS
# ============================

common_labels  = {
  managed_by    = "terraform"
  project       = "my-application"
  cost_center   = "engineering"
  owner         = "devops-team"
  created_by    = "rajkumar"
}