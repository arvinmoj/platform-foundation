# Production Environment Configuration

module "platform" {
  source = "../.."

  bmc_credentials      = var.bmc_credentials
  cluster_name         = var.cluster_name
  control_plane_vip    = var.control_plane_vip
  environment          = var.environment
  kubernetes_version   = var.kubernetes_version
  metallb_address_pool = var.metallb_address_pool
  monitoring_enabled   = var.monitoring_enabled
  network_config       = var.network_config
  servers              = var.servers
  ssh_public_keys      = var.ssh_public_keys
  storage_config       = var.storage_config
  tags                 = var.tags
}
