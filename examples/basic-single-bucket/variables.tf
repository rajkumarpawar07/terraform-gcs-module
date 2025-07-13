variable "bucket_configs" {
  description = "List of bucket configurations"
  type        = list(any)
}

variable "environment" {
  description = "Environment name like dev/test/prod"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "The region to deploy resources in"
  type        = string
  default     = "us-central1"
}
