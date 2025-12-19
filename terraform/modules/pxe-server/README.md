# PXE Server Module

This module configures PXE/TFTP boot infrastructure for automated OS installation.

## Features

- PXE/TFTP server configuration
- iPXE boot menu generation
- Ubuntu autoinstall configurations
- Network boot infrastructure
- DHCP integration (optional)

## Usage

```hcl
module "pxe_server" {
  source = "./modules/pxe-server"

  cluster_name = "production-cluster"
  
  network_config = {
    gateway     = "192.168.1.1"
    subnet_cidr = "192.168.1.0/24"
  }
  
  servers = {
    "k8s-master-01" = {
      ip_address  = "192.168.1.10"
      mac_address = "00:11:22:33:44:55"
      role        = "control-plane"
      # ... other fields
    }
  }
  
  ssh_public_keys = [file("~/.ssh/id_rsa.pub")]
}
```

## Requirements

- TFTP server (tftpd-hpa)
- HTTP server (nginx/apache)
- Network boot support on target servers
- Ubuntu ISO images

## Outputs

- `pxe_server_ip`: IP address of PXE server
- `tftp_directory`: TFTP root directory
- `boot_configurations`: Generated boot configurations
