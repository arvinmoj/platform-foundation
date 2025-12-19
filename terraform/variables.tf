variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "baremetal-k8s"
}

variable "environment" {
  description = "Environment name (production, staging, development)"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["production", "staging", "development"], var.environment)
    error_message = "Environment must be one of: production, staging, development"
  }
}

variable "kubernetes_version" {
  description = "Version of Kubernetes to install"
  type        = string
  default     = "1.28.5"
}

variable "network_config" {
  description = "Network configuration for the cluster"
  type = object({
    gateway     = string
    dns_servers = list(string)
    mtu         = number
    pod_cidr    = string
    service_cidr = string
    subnet_cidr = string
    vlan_id     = optional(number)
  })

  default = {
    gateway      = "192.168.1.1"
    dns_servers  = ["192.168.1.1", "8.8.8.8"]
    mtu          = 1500
    pod_cidr     = "10.244.0.0/16"
    service_cidr = "10.96.0.0/12"
    subnet_cidr  = "192.168.1.0/24"
    vlan_id      = null
  }
}

variable "servers" {
  description = "Physical server configurations"
  type = map(object({
    cpu_cores     = number
    gpu_model     = optional(string)
    gpu_present   = optional(bool, false)
    ip_address    = string
    mac_address   = string
    memory_gb     = number
    rack_location = optional(string)
    role          = string
    storage_disks = list(string)
  }))

  default = {}

  validation {
    condition = alltrue([
      for name, server in var.servers :
      contains(["control-plane", "worker"], server.role)
    ])
    error_message = "Server role must be either 'control-plane' or 'worker'"
  }
}

variable "bmc_credentials" {
  description = "BMC/IPMI credentials for server management"
  type = object({
    password = string
    username = string
  })

  sensitive = true
}

variable "ssh_public_keys" {
  description = "SSH public keys for server access"
  type        = list(string)
  default     = []
}

variable "storage_config" {
  description = "Storage configuration"
  type = object({
    ceph_enabled      = optional(bool, true)
    longhorn_enabled  = optional(bool, false)
    osd_devices       = optional(list(string), [])
    pool_replication  = optional(number, 3)
  })

  default = {
    ceph_enabled     = true
    longhorn_enabled = false
    osd_devices      = []
    pool_replication = 3
  }
}

variable "monitoring_enabled" {
  description = "Enable monitoring stack (Prometheus, Grafana, Alertmanager)"
  type        = bool
  default     = true
}

variable "control_plane_vip" {
  description = "Virtual IP address for control plane load balancer"
  type        = string
  default     = ""
}

variable "metallb_address_pool" {
  description = "IP address pool for MetalLB load balancer"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
