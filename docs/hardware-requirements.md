# Hardware Requirements

## Minimum Requirements

### Control Plane Nodes
- **CPU**: 4 cores (8 recommended)
- **Memory**: 16GB RAM (32GB recommended)
- **Storage**: 100GB SSD for OS + etcd
- **Network**: 2x 1Gbps NICs (bonded)
- **BMC**: IPMI 2.0 or higher (iDRAC, iLO, or standard IPMI)

### Worker Nodes
- **CPU**: 8 cores minimum (16+ recommended)
- **Memory**: 32GB RAM minimum (64GB+ recommended)
- **Storage**: 
  - 100GB SSD for OS
  - Additional disks for Ceph/storage (optional)
- **Network**: 2x 1Gbps NICs minimum (10Gbps recommended, bonded)
- **BMC**: IPMI 2.0 or higher

### GPU Worker Nodes (Optional)
- All worker node requirements plus:
- **GPU**: NVIDIA GPUs with CUDA support
- **Power**: Adequate PSU for GPU load
- **Cooling**: Enhanced cooling for GPU workloads

## Recommended Production Configuration

### Small Cluster (5-10 nodes)
```
Control Plane: 3 nodes
- 8 CPU cores
- 32GB RAM
- 200GB NVMe SSD
- 2x 10Gbps NICs

Workers: 3-7 nodes
- 16 CPU cores
- 64GB RAM
- 500GB NVMe SSD + 2TB HDD for storage
- 2x 10Gbps NICs
```

### Medium Cluster (10-50 nodes)
```
Control Plane: 3 nodes
- 16 CPU cores
- 64GB RAM
- 500GB NVMe SSD
- 2x 10Gbps NICs (bonded LACP)

Workers: 7-47 nodes
- 32 CPU cores
- 128GB RAM
- 1TB NVMe SSD + 4x2TB HDD for Ceph
- 2x 25Gbps NICs (bonded LACP)
```

### Large Cluster (50+ nodes)
```
Control Plane: 5 nodes
- 32 CPU cores
- 128GB RAM
- 1TB NVMe SSD
- 2x 25Gbps NICs (bonded LACP)

Workers: 45+ nodes
- 64+ CPU cores
- 256GB+ RAM
- 2TB NVMe SSD + 6x4TB NVMe for Ceph
- 2x 100Gbps NICs (bonded LACP)
```

## Network Infrastructure

### Required
- **Managed Switch**: VLAN support, LACP, jumbo frames
- **Network Cables**: Cat6/Cat6a minimum, fiber for 10Gbps+
- **Gateway/Router**: NAT, firewall capabilities
- **DNS Server**: Internal DNS resolution (optional but recommended)

### Recommended
- **Redundant Switches**: For high availability
- **Out-of-Band Management Network**: Separate VLAN for BMC
- **BGP-capable Router**: For MetalLB BGP mode
- **10Gbps+ Backbone**: For storage traffic

## Storage Requirements

### Ceph Distributed Storage
- **Minimum**: 3 OSD nodes with 3 disks each
- **Recommended**: 5+ OSD nodes with 4+ disks each
- **Disk Type**: NVMe for performance, SSD for balanced, HDD for capacity
- **Disk Size**: 2TB+ per disk
- **Network**: Dedicated 10Gbps+ network for Ceph traffic

### Local Storage
- **Fast Local Volumes**: NVMe SSDs for databases
- **Replicated Storage**: Longhorn with 3+ replicas
- **Disk Requirements**: Separate disk from OS disk

## BMC/IPMI Requirements

### Supported
- **Dell**: iDRAC 7/8/9
- **HPE**: iLO 3/4/5
- **Supermicro**: IPMI 2.0
- **Generic**: Any IPMI 2.0 compliant BMC

### Required Features
- Power control (on/off/reset)
- Serial-over-LAN (SOL) console
- Sensor monitoring (temperature, power, fans)
- Virtual media support (optional)

### Network Configuration
- Dedicated BMC management network (recommended)
- Static IP addresses
- Accessible from provisioning server
- Firewall rules for IPMI port (623/udp)

## Firmware Requirements

### BIOS/UEFI
- **Boot Order**: Network boot (PXE) first
- **Virtualization**: VT-x/AMD-V enabled
- **IOMMU**: Enabled (for GPU passthrough)
- **Secure Boot**: Disabled (or configured for custom kernels)

### BMC Firmware
- Latest stable version
- IPMI 2.0 support
- Redfish API support (optional but recommended)

## Power and Cooling

### Power
- **UPS**: Recommended for production
- **Redundant PSUs**: Recommended for control plane
- **Power Budget**: Plan for peak load + 20% headroom
- **PDU**: Managed PDUs with monitoring (optional)

### Cooling
- **Rack Cooling**: Hot aisle/cold aisle design
- **Ambient Temperature**: 18-27°C (64-80°F)
- **Airflow**: Front-to-back or side-to-side
- **Monitoring**: Temperature sensors in racks

## Physical Infrastructure

### Rack Space
- **Control Plane**: 1U per node (3-5U total)
- **Workers**: 1-2U per node
- **Networking**: 1-2U for switches
- **Management**: 1U for provisioning server

### Cabling
- **Network**: Structured cabling, labeled
- **Power**: Redundant feeds (if available)
- **Management**: Out-of-band network cables
- **Organization**: Cable management, color coding

## Supported Hardware Vendors

### Tested Configurations
- Dell PowerEdge R640/R650
- HPE ProLiant DL360/DL380
- Supermicro X11/X12 series
- Generic Intel/AMD servers with IPMI

### CPU Compatibility
- Intel Xeon E5/Scalable (v2+)
- AMD EPYC (all generations)
- Intel Core i7/i9 (for dev/test)

### GPU Support
- NVIDIA Tesla/A100/H100
- NVIDIA RTX series (dev/test)
- AMD Instinct (experimental)

## Procurement Checklist

- [ ] Control plane servers ordered (3-5 nodes)
- [ ] Worker servers ordered (3+ nodes)
- [ ] Network switches (1-2 with redundancy)
- [ ] Network cables (copper/fiber)
- [ ] Rack space allocated
- [ ] Power circuits available
- [ ] BMC network configured
- [ ] Provisioning server ready
- [ ] Storage disks for Ceph (optional)
- [ ] GPU cards (if needed)
- [ ] UPS system (recommended)
- [ ] Monitoring/management tools
