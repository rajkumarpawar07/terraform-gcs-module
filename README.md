# Terraform Google Cloud Storage (GCS) Module

A comprehensive, production-ready Terraform module for creating Google Cloud Storage (GCS) buckets with advanced features including versioning, lifecycle policies, public access prevention, and security best practices.

## 🚀 Features

### Core Features
- ✅ **Versioning Enabled** - Automatic object versioning with configurable retention
- ✅ **Lifecycle Policies** - Automated storage class transitions and cleanup
- ✅ **Public Access Prevention** - Enforced by default for security
- ✅ **Uniform Bucket Level Access** - Simplified permission management
- ✅ **Multiple Bucket Support** - Create multiple buckets with for_each loops
- ✅ **Optional Secondary Bucket** - Disaster recovery and backup scenarios

### Advanced Features
- 🔒 **KMS Encryption** - Customer-managed encryption keys
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
terraform-gcs-module/
├── main.tf                     # Main module configuration
├── variables.tf                # Input variables
├── outputs.tf                  # Output values
├── README.md                   # This documentation
└── examples/
    ├── basic-single-bucket/
    │   ├── main.tf            # Basic single bucket usage example
    │   ├── variables.tf       # Example variables
    │   ├── outputs.tf         # Example outputs
    │   └── terraform.tfvars   # Example variable values
    ├── basic-multi-bucket/
    │   ├── main.tf            # Basic multi bucket usage example
    │   ├── variables.tf       # Example variables
    │   ├── outputs.tf         # Example outputs
    │   └── terraform.tfvars   # Example variable values
    └── advanced-multi-bucket/
        ├── main.tf            # Advanced multi bucket usage example
        ├── variables.tf       # Example variables
        ├── outputs.tf         # Example outputs
        └── terraform.tfvars   # Example variable values 

```

# 📋 Versions & Changelog

## Version History

### [v2.0.0] - Latest
**Release Date**: Current Version  
**Breaking Changes**: ⚠️ Major version with new features

#### ✨ Added
- **CORS Configuration** - Cross-origin resource sharing support
- **Retention Policies** - Enhanced data retention management
- **Access Logging** - Comprehensive audit trail capabilities
- **Website Hosting** - Static website hosting configuration
- **KMS Encryption** - Customer-managed encryption keys support
- **Enhanced Security** - Additional security configurations

#### 📝 Usage - examples/advanced-multi-bucket

### [v1.1.0] - Feature Release
**Release Date**: Previous Version  
**Type**: Minor Update

#### ✨ Added
- **Versioning Support** - Object versioning with configurable settings
- **Retention Policy** - Automated object retention management
- **Lifecycle Rules** - Basic lifecycle management capabilities

#### 📝 Usage - examples/basic-multi-bucket

### [v1.0.0] - Initial Release
**Release Date**: First Version  
**Type**: Initial Release

#### ✨ Features
- **Basic Bucket Creation** - Single and multi-bucket support
- **Core Configuration** - Essential bucket settings
- **Simple Setup** - Easy-to-use module structure
- **Basic Security** - Default security configurations

#### 📝 Usage - examples/basic-single-bucket


## 🎯 Version Compatibility

| Feature | v1.0.0 | v1.1.0 | v2.0.0 |
|---------|--------|--------|--------|
| Basic Bucket Creation | ✅ | ✅ | ✅ |
| Multi-bucket Support | ✅ | ✅ | ✅ |
| Versioning | ❌ | ✅ | ✅ |
| Retention Policy | ❌ | ✅ | ✅ |
| Lifecycle Rules | ❌ | ✅ | ✅ |
| CORS Configuration | ❌ | ❌ | ✅ |
| Access Logging | ❌ | ❌ | ✅ |
| Website Hosting | ❌ | ❌ | ✅ |
| KMS Encryption | ❌ | ❌ | ✅ |



## 🚀 Quick Start - 📝 Examples

### Basic Example
```bash
cd examples/basic-single-bucket
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

### Advanced Example
```bash
cd examples/advanced-multi-bucket
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```


## 📊 Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `project_id` | GCP Project ID | `string` | n/a | yes |
| `environment` | Environment name (dev, staging, prod) | `string` | n/a | yes |
| `bucket_configs` | List of bucket configurations | `list(object)` | `[]` | yes |
| `create_secondary_bucket` | Create optional secondary bucket | `bool` | `false` | no |
| `secondary_bucket_config` | Secondary bucket configuration | `object` | `null` | no |
| `lifecycle_rules` | Lifecycle management rules | `list(object)` | `[]` | no |
| `common_labels` | Common labels for all resources | `map(string)` | `{}` | no |
| `iam_bindings` | IAM role bindings | `list(object)` | `[]` | no |
| `enable_access_logs` | Enable access logging | `bool` | `false` | no |
| `log_bucket_name` | Bucket name for access logs | `string` | `null` | no |
| `kms_key_name` | KMS key name for encryption | `string` | `null` | no |
| `force_destroy` | Force destroy bucket even if not empty | `bool` | `false` | no |

### Bucket Configuration Object

```hcl
bucket_configs = [
  {
    name                         = string  # Required: Bucket name
    location                     = string  # Required: GCS location
    storage_class               = string  # Optional: Storage class (default: STANDARD)
    versioning_enabled          = bool    # Optional: Enable versioning (default: true)
    public_access_prevention    = string  # Optional: Public access prevention (default: enforced)
    uniform_bucket_level_access = bool    # Optional: Uniform bucket level access (default: true)
    
    # Optional configurations
    kms_key_name        = string          # Customer-managed encryption key
    force_destroy       = bool            # Force destroy non-empty bucket
    
    # Website configuration (optional)
    website_config = {
      main_page_suffix = string           # Main page suffix (e.g., index.html)
      not_found_page   = string           # 404 page (e.g., 404.html)
    }
    
    # CORS configuration (optional)
    cors_config = [
      {
        origin          = list(string)    # Allowed origins
        method          = list(string)    # Allowed methods
        response_header = list(string)    # Response headers
        max_age_seconds = number          # Max age in seconds
      }
    ]
    
    # Labels (optional)
    labels = map(string)                  # Resource labels
  }
]
```

## 📤 Outputs

| Name | Description |
|------|-------------|
| `bucket_names` | Names of all created buckets |
| `bucket_urls` | URLs of all created buckets |
| `bucket_self_links` | Self-links of all created buckets |
| `bucket_locations` | Locations of all created buckets |
| `secondary_bucket_name` | Name of secondary bucket (if created) |
| `secondary_bucket_url` | URL of secondary bucket (if created) |
| `secondary_bucket_self_link` | Self-link of secondary bucket (if created) |
| `lifecycle_rules_applied` | Number of lifecycle rules applied |
| `total_buckets_created` | Total number of buckets created |
| `kms_key_names` | KMS key names used for encryption |

## 🔧 Module Development

### How to Call This Module

#### Method 1: Git Source (Recommended)
```hcl
module "gcs_buckets" {
  source = "git::https://github.com/rajkumarpawar07/terraform-gcs-module.git?ref=v1.0.0"
  
  # Required variables
  project_id  = var.project_id
  environment = var.environment
  
  # Bucket configurations
  bucket_configs = var.bucket_configs
  
  # Optional variables
  create_secondary_bucket = var.create_secondary_bucket
  lifecycle_rules        = var.lifecycle_rules
  common_labels          = var.common_labels
}
```

#### Method 2: Local Path (Development)
```hcl
module "gcs_buckets" {
  source = "../terraform-gcs-module"
  
  # Variables...
}
```

#### Method 3: Terraform Registry (Future)
```hcl
module "gcs_buckets" {
  source  = "rajkumarpawar07/gcs-module/google"
  version = "~> 1.0"
  
  # Variables...
}
```



### Recommended Workflow
1. **Initialize**: `terraform init`
2. **Format**: `terraform fmt -recursive`
3. **Validate**: `terraform validate`
4. **Plan**: `terraform plan -var-file="terraform.tfvars"`
5. **Apply**: `terraform apply -var-file="terraform.tfvars"`

## 🔧 GCP Resources Created

This module creates the following GCP resources:

### Primary Resources
- **google_storage_bucket** - Main storage buckets
- **google_storage_bucket_versioning** - Versioning configuration
- **google_storage_bucket_public_access_prevention** - Public access prevention
- **google_storage_bucket_uniform_bucket_level_access** - Uniform bucket level access

### Optional Resources
- **google_storage_bucket_lifecycle_configuration** - Lifecycle policies
- **google_storage_bucket_iam_binding** - IAM bindings
- **google_storage_notification** - Pub/Sub notifications
- **google_storage_bucket_cors** - CORS configuration
- **google_storage_bucket_website** - Website configuration
- **google_storage_bucket_logging** - Access logging




## 🚀 Getting Started

1. **Clone the repository**:
   ```bash
   git clone https://github.com/rajkumarpawar07/terraform-gcs-module.git
   cd terraform-gcs-module
   ```

2. **Review the examples**:
   ```bash
   cd examples/basic-single-bucket
   cat main.tf
   ```

3. **Customize variables**:
   ```bash
   cp terraform.tfvars terraform.tfvars
   vim terraform.tfvars
   ```

4. **Deploy**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```


**Made with ❤️ by [Rajkumar Pawar](https://github.com/rajkumarpawar07)**
