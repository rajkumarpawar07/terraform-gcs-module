terraform {
  required_version = ">= 1.0"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "gcs_buckets" {
  source = "git::https://github.com/rajkumarpawar07/terraform-gcs-module.git?ref=v1.0.0"

  bucket_configs = var.bucket_configs
  environment    = var.environment
  project_id     = var.project_id
}


