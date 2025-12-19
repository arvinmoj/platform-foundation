terraform {
  required_version = ">= 1.6.0"

  # Backend configuration
  # Uncomment and configure for remote state
  # backend "s3" {
  #   bucket         = "terraform-state-bucket"
  #   key            = "production/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-locks"
  # }

  required_providers {
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }

    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}
