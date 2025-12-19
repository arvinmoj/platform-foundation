variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}

variable "http_directory" {
  description = "HTTP directory for serving boot files"
  type        = string
  default     = "/srv/http"
}

variable "network_config" {
  description = "Network configuration"
  type = object({
    gateway     = string
    subnet_cidr = string
  })
}

variable "pxe_server_ip" {
  description = "IP address of the PXE server"
  type        = string
  default     = ""
}

variable "servers" {
  description = "Server configurations for PXE boot"
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
  description = "SSH public keys to install on provisioned servers"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "tftp_directory" {
  description = "TFTP root directory for serving boot files"
  type        = string
  default     = "/srv/tftp"
}

variable "ubuntu_version" {
  description = "Ubuntu version to install"
  type        = string
  default     = "22.04"
}
