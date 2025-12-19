# OS Provisioning Module

Handles automated OS installation, disk partitioning, and initial system configuration.

## Features

- Automated Ubuntu installation
- RAID/LVM disk configuration
- Initial system setup
- BMC power control
- Network configuration

## Usage

```hcl
module "os_provisioning" {
  source = "./modules/os-provisioning"

  bmc_credentials = var.bmc_credentials
  cluster_name    = "production-cluster"
  network_config  = var.network_config
  pxe_server_ip   = module.pxe_server.pxe_server_ip
  servers         = var.servers
  ssh_public_keys = var.ssh_public_keys
}
```

## Outputs

- `provisioned_servers`: List of successfully provisioned servers
- `provisioning_status`: Status of each server
