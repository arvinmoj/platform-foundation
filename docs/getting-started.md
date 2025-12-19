# Getting Started Guide

## Prerequisites

Before you begin, ensure you have:

1. **Physical Servers**:
   - 3+ servers with BMC/IPMI access
   - Network connectivity between servers
   - Servers can PXE boot

2. **Provisioning Server**:
   - Ubuntu 22.04 or later
   - Terraform 1.6+
   - Network access to server BMCs
   - Internet connectivity (for downloading packages)

3. **Network Infrastructure**:
   - Managed switch (VLAN support recommended)
   - DHCP server (or configure dnsmasq)
   - DNS server (optional but recommended)

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/platform-foundation.git
cd platform-foundation
```

### 2. Install Dependencies

```bash
# Install Terraform
wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
unzip terraform_1.6.6_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Install required tools
sudo apt-get update
sudo apt-get install -y \
  ipmitool \
  nmap \
  jq \
  curl \
  wget
```

### 3. Configure Your Inventory

```bash
# Copy example configuration
cd terraform/inventories/production
cp terraform.tfvars.example terraform.tfvars

# Edit with your server details
vi terraform.tfvars
```

Example configuration:

```hcl
cluster_name = "my-cluster"

servers = {
  "k8s-master-01" = {
    ip_address    = "192.168.1.10"
    mac_address   = "00:11:22:33:44:55"
    role          = "control-plane"
    cpu_cores     = 16
    memory_gb     = 64
    storage_disks = ["/dev/sda", "/dev/sdb"]
  },
  
  "k8s-worker-01" = {
    ip_address    = "192.168.1.20"
    mac_address   = "00:11:22:33:44:66"
    role          = "worker"
    cpu_cores     = 32
    memory_gb     = 128
    storage_disks = ["/dev/sda", "/dev/sdb", "/dev/sdc"]
  }
}

bmc_credentials = {
  username = "ADMIN"
  password = "your-bmc-password"  # Use environment variable
}
```

### 4. Set Environment Variables

```bash
# Set BMC credentials securely
export TF_VAR_bmc_credentials='{"username":"ADMIN","password":"your-password"}'

# Or use a credentials file
cat > ~/.metalctl/credentials << EOF
BMC_USERNAME=ADMIN
BMC_PASSWORD=your-password
EOF
chmod 600 ~/.metalctl/credentials
```

### 5. Initialize Terraform

```bash
cd terraform/inventories/production
terraform init
```

### 6. Discover Hardware (Optional)

```bash
# Run hardware discovery
terraform apply -target=module.discovery

# Or use metalctl
../../metalctl discover --network 192.168.1.0/24
```

### 7. Setup PXE Server

```bash
# Generate PXE configuration
terraform apply -target=module.pxe_server

# Run PXE server setup script
sudo bash ../../scripts/provisioning/setup-pxe-server-my-cluster.sh
```

### 8. Provision the Cluster

```bash
# Review the plan
terraform plan

# Apply the configuration
terraform apply

# Or use metalctl
../../metalctl provision --config terraform.tfvars --nodes all
```

## Post-Installation

### 1. Verify Cluster Status

```bash
# Check node status
kubectl get nodes

# Check pod status
kubectl get pods --all-namespaces

# Or use metalctl
./metalctl health
```

### 2. Access the Cluster

```bash
# Copy kubeconfig
mkdir -p ~/.kube
scp ubuntu@192.168.1.10:/etc/kubernetes/admin.conf ~/.kube/config

# Test access
kubectl cluster-info
```

### 3. Install Additional Components

```bash
# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Add common repos
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

## Common Tasks

### Add a New Worker Node

1. Update `terraform.tfvars`:
```hcl
servers = {
  # ... existing servers ...
  
  "k8s-worker-03" = {
    ip_address    = "192.168.1.22"
    mac_address   = "00:11:22:33:44:77"
    role          = "worker"
    cpu_cores     = 32
    memory_gb     = 128
    storage_disks = ["/dev/sda", "/dev/sdb"]
  }
}
```

2. Apply changes:
```bash
terraform apply
```

### Remove a Node

1. Drain the node:
```bash
kubectl drain k8s-worker-03 --ignore-daemonsets --delete-emptydir-data
```

2. Delete from cluster:
```bash
kubectl delete node k8s-worker-03
```

3. Update `terraform.tfvars` and remove the server entry

4. Apply changes:
```bash
terraform apply
```

### Update Kubernetes Version

1. Update `terraform.tfvars`:
```hcl
kubernetes_version = "1.29.0"
```

2. Apply changes (this will require manual intervention):
```bash
terraform apply
```

## Troubleshooting

### Servers Not Booting via PXE

1. Check BIOS boot order:
   - Network boot should be first
   - UEFI or Legacy mode configured correctly

2. Verify PXE server is running:
```bash
sudo systemctl status tftpd-hpa
sudo systemctl status nginx
```

3. Check network connectivity:
```bash
ping 192.168.1.100  # PXE server
```

### Cannot Connect to BMC

1. Verify BMC IP address:
```bash
ping 192.168.9.10  # BMC address
```

2. Test IPMI access:
```bash
ipmitool -I lanplus -H 192.168.9.10 -U ADMIN -P password power status
```

3. Check firewall rules:
```bash
sudo ufw status
```

### Kubernetes Nodes Not Ready

1. Check kubelet status:
```bash
ssh ubuntu@192.168.1.10
sudo systemctl status kubelet
sudo journalctl -u kubelet -f
```

2. Check CNI plugin:
```bash
kubectl get pods -n kube-system | grep calico
```

3. Check node conditions:
```bash
kubectl describe node k8s-master-01
```

## Next Steps

- [Hardware Requirements](hardware-requirements.md)
- [Network Design](network-design.md)
- [Storage Configuration](storage-design.md)
- [Operations Guide](operations.md)

## Getting Help

- GitHub Issues: https://github.com/your-org/platform-foundation/issues
- Documentation: https://github.com/your-org/platform-foundation/docs
- Community: https://community.example.com
