variable "bmc_credentials" {
  description = "BMC/IPMI credentials for server management"
  type = object({
    password = string
    username = string
  })

  sensitive = true
}

variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}

variable "discovery_methods" {
  description = "Methods to use for hardware discovery"
  type        = list(string)
  
  default = [
    "ipmi_scan",
    "arp_scan",
    "manual_input",
  ]

  validation {
    condition = alltrue([
      for method in var.discovery_methods :
      contains(["ipmi_scan", "arp_scan", "manual_input"], method)
    ])
    error_message = "Discovery methods must be one of: ipmi_scan, arp_scan, manual_input"
  }
}

variable "network_range" {
  description = "Network range to scan for servers (CIDR notation)"
  type        = string

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.network_range))
    error_message = "Network range must be in CIDR notation (e.g., 192.168.1.0/24)"
  }
}

variable "servers" {
  description = "Manually defined server configurations"
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
}

variable "tags" {
  description = "Tags to apply to discovered resources"
  type        = map(string)
  default     = {}
}
