# ============================
# OUTPUTS FROM MODULE USAGE
# ============================

output "basic_setup_buckets" {
  description = "Basic setup bucket details"
  value       = module.gcs_basic_setup.primary_buckets_details
}

output "secure_setup_buckets" {
  description = "Secure setup bucket details"
  value       = module.gcs_secure_setup.primary_buckets_details
}

output "dev_setup_buckets" {
  description = "Development setup bucket details"
  value       = module.gcs_dev_setup.primary_buckets_details
}

output "website_setup_buckets" {
  description = "Website setup bucket details"
  value       = module.gcs_website_setup.primary_buckets_details
}

output "all_bucket_names" {
  description = "All bucket names created across all module instances"
  value = concat(
    module.gcs_basic_setup.all_bucket_names,
    module.gcs_secure_setup.all_bucket_names,
    module.gcs_dev_setup.all_bucket_names,
    module.gcs_website_setup.all_bucket_names
  )
}

output "versioning_summary" {
  description = "Summary of versioning status across all buckets"
  value = {
    basic_setup   = module.gcs_basic_setup.versioning_status
    secure_setup  = module.gcs_secure_setup.versioning_status
    dev_setup     = module.gcs_dev_setup.versioning_status
    website_setup = module.gcs_website_setup.versioning_status
  }
}

output "service_accounts" {
  description = "Service accounts created for bucket access"
  value = {
    web_service_account       = google_service_account.web_service_account.email
    app_service_account       = google_service_account.app_service_account.email
    analytics_service_account = google_service_account.analytics_service_account.email
  }
}

output "kms_key_name" {
  description = "KMS key name for bucket encryption"
  value       = google_kms_crypto_key.bucket_key.id
}