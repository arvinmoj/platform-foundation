# Network Design

## Network Architecture

### Overview
```
┌─────────────────────────────────────────────────────────┐
│                    Internet/WAN                          │
└────────────────────────┬────────────────────────────────┘
                         │
                    ┌────▼────┐
                    │ Gateway │
                    │ Router  │
                    └────┬────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
   ┌────▼────┐      ┌────▼────┐     ┌────▼────┐
   │ Core    │      │ Core    │     │ BMC     │
   │ Switch  │◄─────┤ Switch  │     │ Switch  │
   │ (Pri)   │ MLAG │ (Sec)   │     │         │
   └────┬────┘      └────┬────┘     └────┬────┘
        │                │                │
   ┌────┴────────────────┴────┐          │
   │    Kubernetes Nodes      │          │
   │  (Bonded NICs - LACP)    │          │
   └──────────────────────────┘          │
                                    ┌─────┴─────┐
                                    │ BMC Ports │
                                    └───────────┘
```

## VLAN Design

### VLAN Segmentation
```hcl
# Management VLAN (VLAN 10)
vlan_10 = {
  name        = "management"
  subnet      = "192.168.10.0/24"
  purpose     = "SSH, management traffic"
  access      = "restricted"
}

# Kubernetes VLAN (VLAN 100)
vlan_100 = {
  name        = "kubernetes"
  subnet      = "192.168.1.0/24"
  purpose     = "Control plane, worker nodes"
  access      = "production"
}

# Storage VLAN (VLAN 200)
vlan_200 = {
  name        = "storage"
  subnet      = "192.168.2.0/24"
  purpose     = "Ceph, NFS, iSCSI"
  access      = "storage_only"
}

# BMC VLAN (VLAN 900)
vlan_900 = {
  name        = "bmc"
  subnet      = "192.168.9.0/24"
  purpose     = "IPMI, iDRAC, iLO"
  access      = "oob_management"
}
```

## Network Bonding

### LACP Configuration
```yaml
# Bond configuration for Kubernetes nodes
bond0:
  mode: 802.3ad  # LACP
  lacp-rate: fast
  mii-mon-interval: 100
  interfaces:
    - ens1f0
    - ens1f1
  mtu: 9000  # Jumbo frames
```

### Bond Modes
- **802.3ad (LACP)**: Active-active, switch support required (recommended)
- **active-backup**: Active-passive, no switch config needed
- **balance-alb**: Adaptive load balancing
- **balance-rr**: Round-robin (testing only)

## IP Address Allocation

### Control Plane (192.168.1.1-192.168.1.50)
```
192.168.1.1       - Gateway
192.168.1.2-4     - Reserved
192.168.1.5       - Control Plane VIP (Keepalived)
192.168.1.10-29   - Control plane nodes (20 max)
192.168.1.30-49   - Reserved for expansion
```

### Workers (192.168.1.50-192.168.1.199)
```
192.168.1.50-149  - General worker nodes
192.168.1.150-179 - GPU worker nodes
192.168.1.180-199 - Storage nodes
```

### Infrastructure (192.168.1.200-192.168.1.254)
```
192.168.1.200-250 - MetalLB address pool
192.168.1.251     - Provisioning server
192.168.1.252     - Jump host
192.168.1.253     - Monitoring
192.168.1.254     - Reserved
```

## Kubernetes Networking

### Pod Network (CNI)
```yaml
# Calico configuration
calico:
  pod_cidr: "10.244.0.0/16"
  ipip_mode: "Always"  # or "CrossSubnet", "Never"
  nat_outgoing: true
  bgp: false  # Enable for BGP routing

# Cilium configuration (alternative)
cilium:
  pod_cidr: "10.244.0.0/16"
  tunnel: "vxlan"  # or "geneve", "disabled"
  ebpf_datapath: true
```

### Service Network
```yaml
service_cidr: "10.96.0.0/12"
dns_service_ip: "10.96.0.10"
```

### Network Policies
```yaml
# Example: Restrict traffic to specific namespaces
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```

## Load Balancer Configuration

### MetalLB
```yaml
# Layer 2 mode (simple)
metallb:
  protocol: layer2
  address_pools:
    - name: default
      addresses:
        - 192.168.1.200-192.168.1.250

# BGP mode (advanced)
metallb:
  protocol: bgp
  peers:
    - peer-address: 192.168.1.1
      peer-asn: 64500
      my-asn: 64512
  address_pools:
    - name: default
      addresses:
        - 192.168.1.200-192.168.1.250
      bgp-advertisements:
        - aggregation-length: 32
```

### HAProxy/Keepalived (Control Plane)
```yaml
# Keepalived VIP configuration
keepalived:
  vip: 192.168.1.5
  interface: bond0
  router_id: 51
  priority:
    master-01: 100
    master-02: 95
    master-03: 90

# HAProxy backend
haproxy:
  frontend:
    bind: "*:6443"
  backend:
    servers:
      - name: master-01
        address: 192.168.1.10:6443
      - name: master-02
        address: 192.168.1.11:6443
      - name: master-03
        address: 192.168.1.12:6443
```

## DNS Configuration

### Internal DNS
```yaml
# CoreDNS configuration
coredns:
  cluster_domain: cluster.local
  upstream_nameservers:
    - 192.168.1.1
    - 8.8.8.8
  
# External DNS (optional)
external_dns:
  provider: cloudflare  # or route53, etc.
  domain: k8s.example.com
  txtOwnerId: k8s-cluster
```

### DNS Records
```
# Control plane
k8s-api.internal.local     -> 192.168.1.5 (VIP)
master-01.internal.local   -> 192.168.1.10
master-02.internal.local   -> 192.168.1.11
master-03.internal.local   -> 192.168.1.12

# Services
*.apps.k8s.example.com     -> MetalLB pool
grafana.k8s.example.com    -> 192.168.1.200
prometheus.k8s.example.com -> 192.168.1.201
```

## Firewall Rules

### Control Plane
```bash
# Kubernetes API
6443/tcp  - API server
2379-2380/tcp - etcd client/peer
10250/tcp - Kubelet API
10251/tcp - kube-scheduler
10252/tcp - kube-controller-manager
```

### Worker Nodes
```bash
10250/tcp - Kubelet API
30000-32767/tcp - NodePort services
```

### CNI (Calico)
```bash
179/tcp   - BGP
4789/udp  - VXLAN
```

### Storage (Ceph)
```bash
3300/tcp  - Ceph monitors
6789/tcp  - Ceph monitors
6800-7300/tcp - Ceph OSDs
```

## Quality of Service (QoS)

### Traffic Prioritization
```yaml
# DSCP marking
priority_classes:
  - class: control-plane
    dscp: EF (46)  # Expedited Forwarding
    traffic:
      - etcd
      - API server
  
  - class: storage
    dscp: AF41 (34)  # Assured Forwarding
    traffic:
      - Ceph
      - NFS
  
  - class: best-effort
    dscp: BE (0)  # Best Effort
    traffic:
      - General workloads
```

## MTU Configuration

### Jumbo Frames
```yaml
# Physical interfaces
physical_mtu: 9000

# VLAN interfaces
vlan_mtu: 9000

# Pod network (account for encapsulation overhead)
pod_mtu: 8950  # VXLAN/IPIP overhead

# Service mesh (if using)
envoy_mtu: 8900
```

## Monitoring and Troubleshooting

### Network Monitoring Tools
```bash
# Bandwidth monitoring
iftop -i bond0

# Connection tracking
conntrack -L

# Network statistics
nstat -az

# BGP sessions (if using Calico BGP)
calicoctl node status
```

### Troubleshooting Commands
```bash
# Test connectivity
ping -M do -s 8972 192.168.1.11  # Test jumbo frames

# Trace route
traceroute -n 192.168.1.11

# Check bond status
cat /proc/net/bonding/bond0

# Check VLAN configuration
ip -d link show

# Test MTU
ping -M do -s 8972 <target>
```

## Security Considerations

### Network Segmentation
- Separate BMC network (VLAN 900)
- Isolate storage traffic (VLAN 200)
- Restrict management access
- Use network policies for pod-to-pod traffic

### Encryption
- TLS for all API communication
- WireGuard/IPsec for inter-node traffic (optional)
- Encrypt etcd data

### Access Control
- Firewall rules between VLANs
- Bastion/jump host for SSH access
- VPN for remote management
