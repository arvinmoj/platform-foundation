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

variable "network_config" {
  description = "Network configuration"
  type = object({
    gateway      = string
    dns_servers  = list(string)
    mtu          = number
    pod_cidr     = string
    service_cidr = string
    subnet_cidr  = string
    vlan_id      = optional(number)
  })
}

variable "pxe_server_ip" {
  description = "IP address of PXE server"
  type        = string
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

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
