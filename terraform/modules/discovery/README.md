# Hardware Discovery Module

This module discovers and inventories physical servers using IPMI/BMC scanning and network discovery.

## Features

- IPMI/BMC server discovery
- Network ARP scanning
- Hardware inventory collection
- Server health monitoring
- Automatic server classification

## Usage

```hcl
module "discovery" {
  source = "./modules/discovery"

  bmc_credentials = {
    password = var.ipmi_password
    username = var.ipmi_username
  }
  
  cluster_name  = "production-cluster"
  network_range = "192.168.1.0/24"
  
  servers = {
    "k8s-master-01" = {
      cpu_cores     = 16
      ip_address    = "192.168.1.10"
      mac_address   = "00:11:22:33:44:55"
      memory_gb     = 64
      rack_location = "Rack-A-U10"
      role          = "control-plane"
      storage_disks = ["/dev/sda", "/dev/sdb"]
    }
  }
}
```

## Requirements

- IPMI/BMC access to servers
- Network connectivity to BMC interfaces
- `ipmitool` installed on provisioning server

## Outputs

- `discovered_servers`: Map of discovered server details
- `inventory_json`: Complete inventory in JSON format
- `server_health`: Health status of all servers
