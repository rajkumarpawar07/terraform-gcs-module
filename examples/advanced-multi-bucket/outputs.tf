# ============================
# BUCKET OUTPUTS
# ============================

output "bucket_names" {
  description = "Names of all buckets created"
  value = {
    web_assets    = "${var.project_id}-web-assets-${local.environment}"
    user_uploads  = "${var.project_id}-user-uploads-${local.environment}"
    data_lake     = "${var.project_id}-data-lake-${local.environment}"
    backups       = var.create_secondary_bucket ? "${var.project_id}-backups-${local.environment}" : null
  }
}

output "bucket_urls" {
  description = "URLs of all buckets created"
  value = {
    web_assets    = "gs://${var.project_id}-web-assets-${local.environment}"
    user_uploads  = "gs://${var.project_id}-user-uploads-${local.environment}"
    data_lake     = "gs://${var.project_id}-data-lake-${local.environment}"
    backups       = var.create_secondary_bucket ? "gs://${var.project_id}-backups-${local.environment}" : null
  }
}


# ============================
# SERVICE ACCOUNTS
# ============================

output "service_accounts" {
  description = "Service accounts with bucket access"
  value = {
    web_service_account       = var.web_service_account
    app_service_account       = var.app_service_account
    analytics_service_account = var.analytics_service_account
  }
  sensitive = true
}

