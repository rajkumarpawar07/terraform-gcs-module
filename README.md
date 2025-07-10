# GCS Reusable Terraform Module with Versioning & Lifecycle Policies

A comprehensive, production-ready Terraform module for creating Google Cloud Storage (GCS) buckets with advanced features including versioning, lifecycle policies, public access prevention, and best practices implementation.

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
  source = "git::https://github.com/rajkumarpawar07/terraform-gcs-module.git?ref=v1.0.0"
  
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
  ]
  
  # Optional second bucket for disaster recovery
  create_secondary_bucket = true
  secondary_bucket_config = {
    name                         = "my-project-backup-prod"
    location                     = "EUROPE-WEST1"
    storage_class               = "COLDLINE"
    versioning_enabled          = true
    public_access_prevention    = "enforced"
    uniform_bucket_level_access = true
    labels = {
      purpose = "backup"
      tier    = "disaster-recovery"
    }
  }
  
  # Lifecycle policies
  lifecycle_rules = [
    {
      condition = {
        age = 30
      }
      action = {
        type          = "SetStorageClass"
        storage_class = "NEARLINE"
      }
    },
    {
      condition = {
        age = 90
      }
      action = {
        type          = "SetStorageClass"
        storage_class = "COLDLINE"
      }
    },
    {
      condition = {
        age = 365
      }
      action = {
        type = "Delete"
      }
    }
  ]
  
  # Common labels for all resources
  common_labels = {
    environment = "production"
    project     = "my-web-app"
    team        = "platform-engineering"
    cost_center = "engineering"
    managed_by  = "terraform"
  }
}
```

### Advanced Usage with KMS and Notifications

```hcl
module "gcs_buckets_advanced" {
  source = "git::https://github.com/rajkumarpawar07/terraform-gcs-module.git?ref=v1.0.0"
  
  project_id  = "my-project-id"
  environment = "production"
  
  bucket_configs = [
    {
      name                         = "my-project-sensitive-data-prod"
      location                     = "US"
      storage_class               = "STANDARD"
      versioning_enabled          = true
      public_access_prevention    = "enforced"
      uniform_bucket_level_access = true
      
      # KMS encryption
      kms_key_name = "projects/my-project-id/locations/us/keyRings/my-keyring/cryptoKeys/my-key"
      
      # Pub/Sub notifications
      notification_config = {
        topic_name = "projects/my-project-id/topics/gcs-notifications"
        payload_format = "JSON_API_V1"
        event_types = [
          "OBJECT_FINALIZE",
          "OBJECT_DELETE"
        ]
      }
      
      # CORS configuration
      cors_config = [
        {
          origin          = ["https://mydomain.com"]
          method          = ["GET", "POST"]
          response_header = ["Content-Type"]
          max_age_seconds = 3600
        }
      ]
      
      labels = {
        purpose = "sensitive-data"
        tier    = "secure"
      }
    }
  ]
  
  # IAM bindings
  iam_bindings = [
    {
      role    = "roles/storage.objectViewer"
      members = [
        "serviceAccount:my-service-account@my-project-id.iam.gserviceaccount.com",
        "group:developers@mydomain.com"
      ]
    }
  ]
  
  common_labels = {
    environment = "production"
    project     = "my-web-app"
    team        = "platform-engineering"
    cost_center = "engineering"
    managed_by  = "terraform"
  }
}
```

### Website Hosting Example

```hcl
module "website_buckets" {
  source = "git::https://github.com/rajkumarpawar07/terraform-gcs-module.git?ref=v1.0.0"
  
  project_id  = "my-website-project"
  environment = "production"
  
  bucket_configs = [
    {
      name                         = "my-website-static-content"
      location                     = "US"
      storage_class               = "STANDARD"
      versioning_enabled          = true
      public_access_prevention    = "inherited"  # Allow public access for website
      uniform_bucket_level_access = true
      
      # Website configuration
      website_config = {
        main_page_suffix = "index.html"
        not_found_page   = "404.html"
      }
      
      # CORS for web assets
      cors_config = [
        {
          origin          = ["*"]
          method          = ["GET", "HEAD"]
          response_header = ["Content-Type", "Cache-Control"]
          max_age_seconds = 86400
        }
      ]
      
      labels = {
        purpose = "website"
        tier    = "frontend"
      }
    }
  ]
  
  # Lifecycle rules for website assets
  lifecycle_rules = [
    {
      condition = {
        age = 7
        matches_storage_class = ["STANDARD"]
      }
      action = {
        type          = "SetStorageClass"
        storage_class = "NEARLINE"
      }
    }
  ]
  
  common_labels = {
    environment = "production"
    project     = "my-website"
    team        = "frontend"
    managed_by  = "terraform"
  }
}
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
| `enable_notifications` | Enable Pub/Sub notifications | `bool` | `false` | no |
| `notification_topics` | List of Pub/Sub topics for notifications | `list(string)` | `[]` | no |
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
    
    # Notification configuration (optional)
    notification_config = {
      topic_name     = string             # Pub/Sub topic name
      payload_format = string             # Payload format (JSON_API_V1, NONE)
      event_types    = list(string)       # Event types to notify
    }
    
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
| `notification_topics` | Pub/Sub topics configured for notifications |

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

### Development Guidelines

#### 1. **Incremental Values with for_each**
```hcl
# Using for_each with index for incremental naming
resource "google_storage_bucket" "buckets" {
  for_each = {
    for idx, config in var.bucket_configs : 
    "${config.name}-${format("%02d", idx)}" => merge(config, { index = idx })
  }
  
  name          = each.value.name
  location      = each.value.location
  storage_class = each.value.storage_class
  
  # Incremental naming pattern
  project = var.project_id
  
  # Apply common labels with incremental values
  labels = merge(
    var.common_labels,
    each.value.labels,
    {
      bucket_index = each.value.index
      created_at   = formatdate("YYYY-MM-DD", timestamp())
    }
  )
}
```

#### 2. **Module Types and Best Practices**

**Type 1: Simple Bucket Creation**
```hcl
# Simple module call for basic bucket creation
module "simple_bucket" {
  source = "git::https://github.com/rajkumarpawar07/terraform-gcs-module.git"
  
  project_id     = "my-project"
  environment    = "dev"
  bucket_configs = [
    {
      name     = "my-simple-bucket"
      location = "US"
    }
  ]
}
```

**Type 2: Advanced Configuration**
```hcl
# Advanced module call with all features
module "advanced_bucket" {
  source = "git::https://github.com/rajkumarpawar07/terraform-gcs-module.git"
  
  project_id              = "my-project"
  environment             = "prod"
  create_secondary_bucket = true
  
  bucket_configs = [
    {
      name                         = "my-advanced-bucket"
      location                     = "US"
      storage_class               = "STANDARD"
      versioning_enabled          = true
      public_access_prevention    = "enforced"
      uniform_bucket_level_access = true
      kms_key_name                = var.kms_key_name
      
      cors_config = [
        {
          origin          = ["https://example.com"]
          method          = ["GET", "POST"]
          response_header = ["Content-Type"]
          max_age_seconds = 3600
        }
      ]
      
      notification_config = {
        topic_name     = "my-topic"
        payload_format = "JSON_API_V1"
        event_types    = ["OBJECT_FINALIZE"]
      }
    }
  ]
  
  lifecycle_rules = [
    {
      condition = {
        age = 30
      }
      action = {
        type          = "SetStorageClass"
        storage_class = "NEARLINE"
      }
    }
  ]
  
  iam_bindings = [
    {
      role    = "roles/storage.objectViewer"
      members = ["serviceAccount:sa@project.iam.gserviceaccount.com"]
    }
  ]
}
```

**Type 3: Multi-Environment Setup**
```hcl
# Multi-environment module usage
module "gcs_buckets_dev" {
  source = "git::https://github.com/rajkumarpawar07/terraform-gcs-module.git"
  
  project_id  = "my-project-dev"
  environment = "dev"
  
  bucket_configs = [
    for i, config in var.bucket_configs : {
      name                         = "${config.name}-${var.environment}-${format("%02d", i)}"
      location                     = config.location
      storage_class               = "STANDARD"
      versioning_enabled          = true
      public_access_prevention    = "enforced"
      uniform_bucket_level_access = true
      
      labels = merge(
        var.common_labels,
        {
          environment = var.environment
          index      = i
        }
      )
    }
  ]
}

module "gcs_buckets_prod" {
  source = "git::https://github.com/rajkumarpawar07/terraform-gcs-module.git"
  
  project_id  = "my-project-prod"
  environment = "prod"
  
  bucket_configs = [
    for i, config in var.bucket_configs : {
      name                         = "${config.name}-${var.environment}-${format("%02d", i)}"
      location                     = config.location
      storage_class               = "STANDARD"
      versioning_enabled          = true
      public_access_prevention    = "enforced"
      uniform_bucket_level_access = true
      kms_key_name                = var.prod_kms_key_name
      
      labels = merge(
        var.common_labels,
        {
          environment = var.environment
          index      = i
        }
      )
    }
  ]
  
  # Production-specific lifecycle rules
  lifecycle_rules = [
    {
      condition = {
        age = 30
      }
      action = {
        type          = "SetStorageClass"
        storage_class = "NEARLINE"
      }
    },
    {
      condition = {
        age = 90
      }
      action = {
        type          = "SetStorageClass"
        storage_class = "COLDLINE"
      }
    },
    {
      condition = {
        age = 365
      }
      action = {
        type = "Delete"
      }
    }
  ]
}
```

## 🔄 Terraform vs Code Integration

### VS Code Extensions
- **Terraform** - HashiCorp Terraform support
- **Terraform doc snippets** - Documentation snippets
- **HashiCorp HCL** - HCL syntax highlighting

### VS Code Settings
```json
{
  "terraform.experimentalFeatures": {
    "validateOnSave": true,
    "prefillRequiredFields": true
  },
  "terraform.languageServer": {
    "external": true,
    "pathToBinary": "terraform-ls"
  }
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

## 📝 Examples

### Basic Example
```bash
cd examples/basic
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

### Advanced Example
```bash
cd examples/advanced
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

### Website Example
```bash
cd examples/website
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

## 📚 Best Practices Implemented

### Security
- **Public Access Prevention**: Enforced by default
- **Uniform Bucket Level Access**: Enabled by default
- **KMS Encryption**: Support for customer-managed keys
- **IAM Bindings**: Fine-grained access control

### Performance
- **Storage Classes**: Optimized for different use cases
- **Lifecycle Policies**: Automated cost optimization
- **Regional/Multi-regional**: Location-based optimization

### Maintainability
- **Versioning**: Enabled by default for data protection
- **Labeling**: Comprehensive tagging strategy
- **Documentation**: Extensive inline comments
- **Validation**: Input validation for all variables

### Cost Optimization
- **Lifecycle Rules**: Automated storage class transitions
- **Deletion Policies**: Automated cleanup of old objects
- **Storage Class Selection**: Right-sizing for use cases

## 🚀 Getting Started

1. **Clone the repository**:
   ```bash
   git clone https://github.com/rajkumarpawar07/terraform-gcs-module.git
   cd terraform-gcs-module
   ```

2. **Review the examples**:
   ```bash
   cd examples/basic
   cat main.tf
   ```

3. **Customize variables**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   vim terraform.tfvars
   ```

4. **Deploy**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-feature`
3. Commit your changes: `git commit -am 'Add new feature'`
4. Push to the branch: `git push origin feature/new-feature`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- HashiCorp for Terraform
- Google Cloud Platform for GCS
- Terraform Google Provider maintainers
- Open source community for best practices

## 📞 Support

If you have questions or need help:

1. Check the [examples](examples/) directory
2. Review the [documentation](docs/)
3. Open an [issue](https://github.com/rajkumarpawar07/terraform-gcs-module/issues)
4. Contact the maintainer: [@rajkumarpawar07](https://github.com/rajkumarpawar07)

---

**Made with ❤️ by [Rajkumar Pawar](https://github.com/rajkumarpawar07)**
