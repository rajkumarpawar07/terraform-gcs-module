terraform {
  required_version = ">= 1.0"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "gcs_buckets" {
  source = "git::https://github.com/rajkumarpawar07/terraform-gcs-module.git"

  project_id  = var.project_id
  environment = "dev"

  bucket_configs = [
    {
      name                         = "rajkumar-cloudshell-primary-bucket"
      location                     = "US"
      storage_class                = "STANDARD"
      public_access_prevention     = "enforced"
      uniform_bucket_level_access  = true
      force_destroy                = true
      versioning_enabled           = true
      labels                       = { usage = "test" }
      
    }
  ]

  create_secondary_bucket = false
}


# Variable declarations
variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
}

variable "region" {
  description = "The region to deploy resources in"
  type        = string
  default     = "us-central1"
}