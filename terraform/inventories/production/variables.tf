variable "bmc_credentials" {
  description = "BMC/IPMI credentials"
  type = object({
    password = string
    username = string
  })
  sensitive = true
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "control_plane_vip" {
  description = "Control plane VIP"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}

variable "metallb_address_pool" {
  description = "MetalLB address pool"
  type        = list(string)
}

variable "monitoring_enabled" {
  description = "Enable monitoring"
  type        = bool
}

variable "network_config" {
  description = "Network configuration"
  type = object({
    dns_servers  = list(string)
    gateway      = string
    mtu          = number
    pod_cidr     = string
    service_cidr = string
    subnet_cidr  = string
    vlan_id      = optional(number)
  })
}

variable "servers" {
  description = "Server configurations"
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
}

variable "ssh_public_keys" {
  description = "SSH public keys"
  type        = list(string)
}

variable "storage_config" {
  description = "Storage configuration"
  type = object({
    ceph_enabled     = optional(bool, true)
    longhorn_enabled = optional(bool, false)
    osd_devices      = optional(list(string), [])
    pool_replication = optional(number, 3)
  })
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
}
