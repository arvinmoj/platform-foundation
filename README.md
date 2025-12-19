# Bare-Metal Kubernetes Platform Foundation

**A Terraform-based Infrastructure as Code platform for provisioning and managing production-grade Kubernetes clusters on physical Ubuntu servers**

## Overview

This platform automates the complete lifecycle of bare-metal Kubernetes infrastructure, from hardware discovery through cluster deployment and ongoing operations. It eliminates cloud provider dependencies and provides full control over physical infrastructure.

## Features

- **Zero Touch Provisioning**: Automated provisioning from bare-metal to running Kubernetes
- **Hardware Discovery**: Automatic detection and inventory of physical servers via IPMI/BMC
- **PXE Boot Infrastructure**: Network-based OS installation with iPXE/TFTP
- **High Availability**: Multi-master control plane with load balancing
- **Distributed Storage**: Rook/Ceph and Longhorn integration
- **Bare-metal Load Balancing**: MetalLB for LoadBalancer services
- **Hardware Monitoring**: IPMI/BMC monitoring with alerting
- **Firmware Management**: Automated firmware updates
- **Multi-vendor Support**: Dell iDRAC, HPE iLO, IPMI-compliant BMCs

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                Provisioning Server                       │
│  • Terraform Controller                                │
│  • PXE/TFTP Server                                     │
│  • Image Registry (Ubuntu, custom images)              │
│  • DHCP Server (optional)                              │
│  • Inventory Database (PostgreSQL)                     │
└───────────────────────────┬─────────────────────────────┘
                            │
    ┌───────────────────────┼───────────────────────┐
    │                       │                       │
┌───▼─────┐           ┌─────▼─────┐           ┌─────▼─────┐
│  BMC    │           │  BMC      │           │  BMC      │
│ Switch  │           │ Switch    │           │ Switch    │
└───┬─────┘           └─────┬─────┘           └─────┬─────┘
    │                       │                       │
┌───▼─────┐           ┌─────▼─────┐           ┌─────▼─────┐
│ Rack A  │           │ Rack B    │           │ Rack C    │
│ Masters │           │ Workers   │           │ GPU/Storage│
└─────────┘           └───────────┘           └───────────┘
```

## Quick Start

### Prerequisites

- Physical servers with IPMI/BMC access
- Network infrastructure (managed switch recommended)
- Provisioning server (Ubuntu 22.04+)
- Terraform 1.6+
- Network connectivity to server BMCs

### Installation

```bash
# Clone the repository
git clone https://github.com/your-org/platform-foundation.git
cd platform-foundation

# Configure your inventory
cp inventories/production/terraform.tfvars.example inventories/production/terraform.tfvars
vi inventories/production/terraform.tfvars

# Initialize Terraform
cd inventories/production
terraform init

# Discover hardware
terraform apply -target=module.discovery

# Review discovered hardware
terraform show

# Provision full cluster
terraform apply
```

### Using the CLI

```bash
# Discover hardware
./metalctl discover --network 192.168.1.0/24

# View inventory
./metalctl inventory --format json

# Provision nodes
./metalctl provision --config cluster.yaml --nodes k8s-master-[01:03]

# Power management
./metalctl power --state on --nodes k8s-worker-01,k8s-worker-02

# Access console
./metalctl console --node k8s-master-01

# Update firmware
./metalctl firmware --update --node all

# Initialize storage
./metalctl storage --initialize --node k8s-worker-01 --disks /dev/sdb,/dev/sdc
```

## Project Structure

```
baremetal-k8s-platform/
├── terraform/
│   ├── providers/          # Custom Terraform providers
│   ├── modules/            # Reusable Terraform modules
│   └── inventories/        # Environment-specific configs
├── ansible/                # Ansible playbooks for complex tasks
├── pxe/                    # PXE boot configurations
├── images/                 # OS images and firmware
├── scripts/                # Operational scripts
├── docs/                   # Documentation
└── examples/               # Example configurations
```

## Modules

### Core Modules

- **[discovery](terraform/modules/discovery)**: Hardware discovery and inventory management
- **[pxe-server](terraform/modules/pxe-server)**: PXE/TFTP boot infrastructure
- **[os-provisioning](terraform/modules/os-provisioning)**: Operating system installation
- **[networking](terraform/modules/networking)**: Network configuration and CNI setup
- **[kubernetes](terraform/modules/kubernetes)**: Kubernetes cluster installation
- **[storage](terraform/modules/storage)**: Storage provisioning and management
- **[loadbalancer](terraform/modules/loadbalancer)**: Load balancer configuration
- **[monitoring](terraform/modules/monitoring)**: Monitoring and alerting

## Configuration Example

```hcl
module "baremetal_cluster" {
  source = "./modules/baremetal-platform"
  
  # Hardware Configuration
  servers = {
    "k8s-master-01" = {
      ip_address    = "192.168.1.10"
      mac_address   = "00:11:22:33:44:55"
      cpu_cores     = 16
      memory_gb     = 64
      storage_disks = ["/dev/sda", "/dev/sdb"]
      role          = "control-plane"
      rack_location = "Rack-A-U10"
    }
  }
  
  # Network Configuration
  network = {
    subnet_cidr    = "192.168.1.0/24"
    gateway        = "192.168.1.1"
    dns_servers    = ["192.168.1.1", "8.8.8.8"]
    vlan_id        = 100
    bond_mode      = "802.3ad"
    mtu            = 9000
  }
  
  # Kubernetes Configuration
  kubernetes = {
    version            = "1.28"
    cni_plugin         = "calico"
    pod_cidr           = "10.244.0.0/16"
    service_cidr       = "10.96.0.0/12"
    control_plane_vip  = "192.168.1.5"
  }
}
```

## Roadmap

### Phase 1: MVP (Weeks 1-4)
- [x] Hardware discovery module
- [ ] Basic PXE provisioning
- [ ] Single-node Kubernetes
- [ ] Local storage
- [ ] Basic networking

### Phase 2: Production Ready (Weeks 5-8)
- [ ] HA control plane
- [ ] RAID/LVM automation
- [ ] MetalLB integration
- [ ] Rook/Ceph storage
- [ ] Hardware monitoring

### Phase 3: Advanced Features (Weeks 9-12)
- [ ] GPU support
- [ ] BGP networking
- [ ] Firmware automation
- [ ] Predictive failure analysis
- [ ] Self-healing capabilities

## Documentation

- [Hardware Requirements](docs/hardware-requirements.md)
- [Network Design](docs/network-design.md)
- [Storage Architecture](docs/storage-design.md)
- [Operations Guide](docs/operations.md)
- [Troubleshooting](docs/troubleshooting.md)

## Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) for details.

## License

See [LICENSE](LICENSE) file for details.

## Support

For issues, questions, or contributions, please open an issue on GitHub.
Terraform-based platform foundation for Kubernetes clusters on Ubuntu Server.
