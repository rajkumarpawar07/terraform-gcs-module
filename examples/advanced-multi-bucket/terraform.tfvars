
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
