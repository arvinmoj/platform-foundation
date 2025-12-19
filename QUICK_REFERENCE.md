# Quick Reference Card

## Project Commands

### Terraform Operations
```bash
# Initialize
cd terraform/inventories/production
terraform init

# Plan changes
terraform plan

# Apply configuration
terraform apply

# Destroy infrastructure
terraform destroy

# Target specific module
terraform apply -target=module.discovery
```

### metalctl CLI
```bash
# Discover hardware
./metalctl discover --network 192.168.1.0/24

# Show inventory
./metalctl inventory --format table
./metalctl inventory --format json
./metalctl inventory --format csv

# Provision cluster
./metalctl provision --config cluster.yaml --nodes all

# Power management
./metalctl power --state on --nodes k8s-master-01
./metalctl power --state off --nodes k8s-worker-01,k8s-worker-02
./metalctl power --state reset --nodes all

# Console access
./metalctl console --node k8s-master-01

# Firmware updates
./metalctl firmware --check --node all
./metalctl firmware --update --node k8s-master-01

# Storage initialization
./metalctl storage --initialize --node k8s-worker-01 --disks /dev/sdb,/dev/sdc

# Health check
./metalctl health

# Version info
./metalctl version
```

## Kubernetes Operations

### Cluster Management
```bash
# Get nodes
kubectl get nodes -o wide

# Get all resources
kubectl get all --all-namespaces

# Cluster info
kubectl cluster-info

# Component status
kubectl get componentstatuses
```

### Node Operations
```bash
# Drain node (maintenance)
kubectl drain k8s-worker-01 --ignore-daemonsets --delete-emptydir-data

# Cordon node (prevent scheduling)
kubectl cordon k8s-worker-01

# Uncordon node (allow scheduling)
kubectl uncordon k8s-worker-01

# Delete node
kubectl delete node k8s-worker-01
```

### Resource Monitoring
```bash
# Node resource usage
kubectl top nodes

# Pod resource usage
kubectl top pods --all-namespaces

# Describe node
kubectl describe node k8s-master-01

# Get events
kubectl get events --all-namespaces --sort-by='.lastTimestamp'
```

## IPMI Commands

### Power Control
```bash
# Power status
ipmitool -I lanplus -H 192.168.9.10 -U ADMIN -P password power status

# Power on
ipmitool -I lanplus -H 192.168.9.10 -U ADMIN -P password power on

# Power off
ipmitool -I lanplus -H 192.168.9.10 -U ADMIN -P password power off

# Power reset
ipmitool -I lanplus -H 192.168.9.10 -U ADMIN -P password power reset
```

### Monitoring
```bash
# Sensor data
ipmitool -I lanplus -H 192.168.9.10 -U ADMIN -P password sensor

# FRU information
ipmitool -I lanplus -H 192.168.9.10 -U ADMIN -P password fru print

# System event log
ipmitool -I lanplus -H 192.168.9.10 -U ADMIN -P password sel list
```

### Console Access
```bash
# Serial-over-LAN
ipmitool -I lanplus -H 192.168.9.10 -U ADMIN -P password sol activate
```

## Network Commands

### Bond Status
```bash
# Check bond
cat /proc/net/bonding/bond0

# Interface status
ip link show

# IP configuration
ip addr show
```

### Connectivity Testing
```bash
# Ping test
ping -c 3 192.168.1.10

# MTU test (jumbo frames)
ping -M do -s 8972 192.168.1.10

# Traceroute
traceroute -n 192.168.1.10

# Port test
nc -zv 192.168.1.10 6443
```

### Network Troubleshooting
```bash
# ARP table
ip neigh show

# Route table
ip route show

# Network statistics
netstat -s

# Connection tracking
conntrack -L
```

## Storage Commands

### Ceph Operations
```bash
# Ceph status
kubectl exec -n rook-ceph deploy/rook-ceph-tools -- ceph status

# Health detail
kubectl exec -n rook-ceph deploy/rook-ceph-tools -- ceph health detail

# OSD status
kubectl exec -n rook-ceph deploy/rook-ceph-tools -- ceph osd status

# Storage usage
kubectl exec -n rook-ceph deploy/rook-ceph-tools -- ceph df
```

### Volume Management
```bash
# List PVs
kubectl get pv

# List PVCs
kubectl get pvc --all-namespaces

# Describe PVC
kubectl describe pvc my-pvc

# Delete PVC
kubectl delete pvc my-pvc
```

### Disk Operations
```bash
# List disks
lsblk

# Disk usage
df -h

# Smart status
smartctl -a /dev/sda
```

## Troubleshooting

### Logs
```bash
# Kubelet logs
journalctl -u kubelet -f

# Container logs
kubectl logs -f <pod-name>

# Previous container logs
kubectl logs --previous <pod-name>

# All containers in pod
kubectl logs <pod-name> --all-containers=true
```

### Pod Debugging
```bash
# Describe pod
kubectl describe pod <pod-name>

# Execute command in pod
kubectl exec -it <pod-name> -- /bin/bash

# Port forward
kubectl port-forward <pod-name> 8080:80

# Debug node
kubectl debug node/<node-name> -it --image=ubuntu
```

### DNS Testing
```bash
# Test DNS resolution
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup kubernetes.default

# CoreDNS logs
kubectl logs -n kube-system -l k8s-app=kube-dns -f
```

## Environment Variables

### Terraform
```bash
# Set BMC credentials
export TF_VAR_bmc_credentials='{"username":"ADMIN","password":"password"}'

# Enable verbose logging
export TF_LOG=DEBUG

# Custom log file
export TF_LOG_PATH=./terraform.log
```

### Kubernetes
```bash
# Set kubeconfig
export KUBECONFIG=/etc/kubernetes/admin.conf

# Set namespace
export NAMESPACE=production

# Set context
kubectl config use-context my-cluster
```

## File Locations

### Terraform
```
terraform/
├── main.tf                      # Root configuration
├── variables.tf                 # Input variables
├── outputs.tf                   # Outputs
├── inventories/production/      # Production environment
│   └── terraform.tfvars        # Variable values
└── modules/                     # Reusable modules
```

### Generated Files
```
terraform/inventories/
├── production-cluster-inventory.json    # Hardware inventory
└── production-cluster-inventory.csv     # Inventory (CSV)

scripts/
├── discovery/                           # Discovery scripts
├── provisioning/                        # Provisioning scripts
└── healthchecks/                        # Health check scripts

pxe/
├── dhcpd-production-cluster.conf       # DHCP config
└── dnsmasq-production-cluster.conf     # dnsmasq config
```

### Kubernetes
```
/etc/kubernetes/
├── admin.conf           # Admin kubeconfig
├── kubelet.conf         # Kubelet config
├── pki/                 # Certificates
└── manifests/           # Static pod manifests

/var/lib/kubelet/        # Kubelet data
/var/lib/etcd/           # etcd data
```

## Important Ports

### Kubernetes
- **6443**: API server
- **2379-2380**: etcd client/peer
- **10250**: Kubelet API
- **10251**: kube-scheduler
- **10252**: kube-controller-manager
- **30000-32767**: NodePort services

### Network
- **179**: BGP (Calico)
- **4789**: VXLAN
- **623**: IPMI

### Storage
- **3300, 6789**: Ceph monitors
- **6800-7300**: Ceph OSDs

## Quick Diagnostics

```bash
# System status
systemctl status kubelet
systemctl status docker

# Network connectivity
ping -c 3 8.8.8.8
curl -k https://192.168.1.5:6443

# Disk space
df -h /var/lib/kubelet
df -h /var/lib/docker

# Memory usage
free -h

# CPU usage
top -bn1 | head -20

# Process count
ps aux | wc -l
```

## Emergency Contacts

- **Documentation**: See [docs/](docs/)
- **Issues**: GitHub Issues
- **Wiki**: Project Wiki
- **Community**: Community Forum

---

**Keep this card handy for quick reference!**
