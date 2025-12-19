output "cluster_name" {
  description = "Name of the Kubernetes cluster"
  value       = var.cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint"
  value       = var.control_plane_vip != "" ? "https://${var.control_plane_vip}:6443" : ""
}

output "control_plane_nodes" {
  description = "Control plane node information"
  value = {
    for name, server in var.servers :
    name => {
      ip_address = server.ip_address
      role       = server.role
    }
    if server.role == "control-plane"
  }
}

output "worker_nodes" {
  description = "Worker node information"
  value = {
    for name, server in var.servers :
    name => {
      gpu_model  = server.gpu_model
      gpu_present = server.gpu_present
      ip_address = server.ip_address
      role       = server.role
    }
    if server.role == "worker"
  }
}

output "network_config" {
  description = "Network configuration summary"
  value = {
    gateway      = var.network_config.gateway
    pod_cidr     = var.network_config.pod_cidr
    service_cidr = var.network_config.service_cidr
    subnet_cidr  = var.network_config.subnet_cidr
  }
}

output "metallb_addresses" {
  description = "MetalLB IP address pool"
  value       = var.metallb_address_pool
}

output "storage_configuration" {
  description = "Storage configuration summary"
  value = {
    ceph_enabled     = var.storage_config.ceph_enabled
    longhorn_enabled = var.storage_config.longhorn_enabled
    pool_replication = var.storage_config.pool_replication
  }
}
