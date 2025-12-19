provider "local" {
  # Local file provider for configuration management
}

provider "null" {
  # Null provider for executing local commands
}

provider "random" {
  # Random provider for generating secrets and IDs
}

provider "tls" {
  # TLS provider for certificate generation
}

provider "http" {
  # HTTP provider for API calls and health checks
}

provider "external" {
  # External provider for custom data sources
}
