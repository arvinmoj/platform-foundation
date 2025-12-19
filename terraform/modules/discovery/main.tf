# Hardware Discovery Module
# Discovers and inventories physical servers using IPMI/BMC scanning

locals {
  # Server classification
  all_servers = var.servers

  control_plane_servers = {
    for name, server in local.all_servers :
    name => server
    if server.role == "control-plane"
  }

  worker_servers = {
    for name, server in local.all_servers :
    name => server
    if server.role == "worker"
  }

  # Inventory structure
  inventory = {
    cluster_name = var.cluster_name
    discovery_timestamp = timestamp()
    network_range = var.network_range
    servers = {
      for name, server in local.all_servers :
      name => merge(
        server,
        {
          hostname = name
          tags     = var.tags
        }
      )
    }
    summary = {
      control_plane_count = length(local.control_plane_servers)
      total_cpu_cores = sum([
        for server in local.all_servers :
        server.cpu_cores
      ])
      total_memory_gb = sum([
        for server in local.all_servers :
        server.memory_gb
      ])
      total_servers = length(local.all_servers)
      worker_count  = length(local.worker_servers)
    }
  }
}

# Save inventory to local file
resource "local_file" "inventory" {
  content  = jsonencode(local.inventory)
  filename = "${path.module}/../../inventories/${var.cluster_name}-inventory.json"

  file_permission = "0644"
}

# Generate server inventory CSV
resource "local_file" "inventory_csv" {
  content = join("\n", concat(
    ["hostname,ip_address,mac_address,role,cpu_cores,memory_gb,rack_location"],
    [
      for name, server in local.all_servers :
      "${name},${server.ip_address},${server.mac_address},${server.role},${server.cpu_cores},${server.memory_gb},${try(server.rack_location, "")}"
    ]
  ))
  
  filename = "${path.module}/../../inventories/${var.cluster_name}-inventory.csv"

  file_permission = "0644"
}

# Discovery scripts for automated scanning
resource "local_file" "ipmi_discovery_script" {
  content = templatefile("${path.module}/scripts/ipmi-discovery.sh.tftpl", {
    bmc_password  = var.bmc_credentials.password
    bmc_username  = var.bmc_credentials.username
    cluster_name  = var.cluster_name
    network_range = var.network_range
  })
  
  filename = "${path.module}/../../scripts/discovery/ipmi-discovery-${var.cluster_name}.sh"

  file_permission = "0755"
}

resource "local_file" "arp_discovery_script" {
  content = templatefile("${path.module}/scripts/arp-discovery.sh.tftpl", {
    cluster_name  = var.cluster_name
    network_range = var.network_range
  })
  
  filename = "${path.module}/../../scripts/discovery/arp-discovery-${var.cluster_name}.sh"

  file_permission = "0755"
}

# Health check script generation
resource "local_file" "health_check_script" {
  content = templatefile("${path.module}/scripts/health-check.sh.tftpl", {
    bmc_password = var.bmc_credentials.password
    bmc_username = var.bmc_credentials.username
    servers = {
      for name, server in local.all_servers :
      name => {
        bmc_ip     = server.ip_address
        hostname   = name
        ip_address = server.ip_address
      }
    }
  })
  
  filename = "${path.module}/../../scripts/healthchecks/health-check-${var.cluster_name}.sh"

  file_permission = "0755"
}
