# Main Terraform configuration for bare-metal Kubernetes platform
# This orchestrates all modules to provision a complete K8s cluster

locals {
  cluster_fqdn = "${var.cluster_name}.${var.environment}.local"

  common_tags = merge(
    {
      Cluster     = var.cluster_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Platform    = "BareMetal"
    },
    var.tags
  )

  control_plane_nodes = {
    for name, server in var.servers :
    name => server
    if server.role == "control-plane"
  }

  worker_nodes = {
    for name, server in var.servers :
    name => server
    if server.role == "worker"
  }
}

# Hardware Discovery Module
module "discovery" {
  source = "./modules/discovery"

  bmc_credentials = var.bmc_credentials
  cluster_name    = var.cluster_name
  network_range   = var.network_config.subnet_cidr
  servers         = var.servers
  tags            = local.common_tags
}

# PXE Server Module
module "pxe_server" {
  source = "./modules/pxe-server"

  cluster_name = var.cluster_name
  network_config = {
    gateway     = var.network_config.gateway
    subnet_cidr = var.network_config.subnet_cidr
  }
  servers = var.servers
  ssh_public_keys = var.ssh_public_keys
  tags    = local.common_tags

  depends_on = [module.discovery]
}

# OS Provisioning Module
module "os_provisioning" {
  source = "./modules/os-provisioning"

  bmc_credentials = var.bmc_credentials
  cluster_name    = var.cluster_name
  network_config  = var.network_config
  pxe_server_ip   = module.pxe_server.pxe_server_ip
  servers         = var.servers
  ssh_public_keys = var.ssh_public_keys
  tags            = local.common_tags

  depends_on = [module.pxe_server]
}

# Networking Module
module "networking" {
  source = "./modules/networking"

  cluster_name   = var.cluster_name
  network_config = var.network_config
  servers        = var.servers
  tags           = local.common_tags

  depends_on = [module.os_provisioning]
}

# Kubernetes Installation Module
module "kubernetes" {
  source = "./modules/kubernetes"

  cluster_name        = var.cluster_name
  control_plane_nodes = local.control_plane_nodes
  control_plane_vip   = var.control_plane_vip
  kubernetes_version  = var.kubernetes_version
  network_config      = var.network_config
  tags                = local.common_tags
  worker_nodes        = local.worker_nodes

  depends_on = [module.networking]
}

# Storage Module
module "storage" {
  source = "./modules/storage"

  cluster_name   = var.cluster_name
  servers        = var.servers
  storage_config = var.storage_config
  tags           = local.common_tags

  depends_on = [module.kubernetes]
}

# Load Balancer Module
module "loadbalancer" {
  source = "./modules/loadbalancer"

  cluster_name          = var.cluster_name
  control_plane_nodes   = local.control_plane_nodes
  control_plane_vip     = var.control_plane_vip
  metallb_address_pool  = var.metallb_address_pool
  tags                  = local.common_tags

  depends_on = [module.kubernetes]
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"

  bmc_credentials   = var.bmc_credentials
  cluster_name      = var.cluster_name
  monitoring_enabled = var.monitoring_enabled
  servers           = var.servers
  tags              = local.common_tags

  depends_on = [module.kubernetes]
}
