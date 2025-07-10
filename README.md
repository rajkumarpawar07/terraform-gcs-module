# GCS Reusable Terraform Module with Versioning & Lifecycle Policies

[![Terraform](https://img.shields.io/badge/Terraform-%23623CE4.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Google Cloud](https://img.shields.io/badge/GoogleCloud-%234285F4.svg?style=for-the-badge&logo=google-cloud&logoColor=white)](https://cloud.google.com/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)

A comprehensive, production-ready Terraform module for creating Google Cloud Storage (GCS) buckets with advanced features including versioning, lifecycle policies, public access prevention, and best practices implementation.

## 🚀 Features

### Core Features
- ✅ **Versioning Enabled** - Automatic object versioning with configurable retention
- ✅ **Lifecycle Policies** - Automated storage class transitions and cleanup
- ✅ **Public Access Prevention** - Enforced by default for security
- ✅ **Uniform Bucket Level Access** - Simplified permission management
- ✅ **Multiple Bucket Support** - Create multiple buckets with for_each loops
- ✅ **Optional Secondary Bucket** - Disaster recovery and backup scenario

### Advanced Features
- 🔒 **KMS Encryption** - Customer-managed encryption keys
- 🔔 **Pub/Sub Notifications** - Event-driven architecture support
- 🌐 **CORS Configuration** - Cross-origin resource sharing
- 📊 **Access Logging** - Detailed audit trails
- 🏷️ **Comprehensive Labeling** - Resource organization and cost tracking
- 🔐 **IAM Bindings** - Fine-grained access control

### Best Practices
- 🎯 **Incremental Values** - Index-based bucket organization
- 📝 **Comprehensive Documentation** - Well-documented code with examples
- ✅ **Input Validation** - Robust variable validation
- 🔄 **Terraform State Management** - Proper resource dependencies
- 🚫 **Security by Default** - Secure defaults with opt-in flexibility

## 📋 Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| google | ~> 4.5 |
| google-beta | ~> 4.5 |

## 🏗️ Module Structure

```
terraform-gcp-gcs-module/
├── main.tf                 # Main module configuration
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── README.md              # This documentation
├── examples/
│   ├── basic/
│   │   ├── main.tf        # Basic usage example
│   │   ├── variables.tf   # Example variables
│   │   └── terraform.tfvars.example
│   ├── advanced/
│   │   └── main.tf        # Advanced usage example
│   └── website/
│       └── main.tf        # Website hosting example
├── modules/
│   └── bucket-policy/     # Sub-module for advanced policies
└── docs/
    ├── CHANGELOG.md
    └── MIGRATION.md
```

## 🚀 Quick Start

### Basic Usage

```hcl
module "gcs_buckets" {
  source = "git::https://github.com/your-org/terraform-gcp-gcs-module.git?ref=v1.0.0"
  
  project_id  = "my-project-id"
  environment = "production"
  
  bucket_configs = [
    {
      name                         = "my-project-web-assets-prod"
      location                     = "US"
      storage_class               = "STANDARD"
      versioning_enabled          = true
      public_access_prevention    = "enforced"
      uniform_bucket_level_access = true
      labels = {
        purpose = "web-assets"
        tier    = "frontend"
      }
    },
    {
      name                         = "my-project-user-uploads-prod"
      location                     = "US-CENTRAL1"
      storage_class               = "STANDARD"
      versioning_enabled          = true
      public_access_prevention    = "enforced"
      uniform_bucket_level_access = true
      labels = {
        purpose = "user-uploads"
        tier    = "application"
      }
    }