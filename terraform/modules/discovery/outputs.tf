output "discovered_servers" {
  description = "Map of discovered server details"
  value       = local.all_servers
}

output "inventory_json" {
  description = "Complete inventory in JSON format"
  value       = jsonencode(local.inventory)
}

output "server_count" {
  description = "Total number of discovered servers"
  value = {
    control_plane = length(local.control_plane_servers)
    total         = length(local.all_servers)
    worker        = length(local.worker_servers)
  }
}

output "server_health" {
  description = "Health status of all servers"
  value = {
    for name, server in local.all_servers :
    name => {
      health_check_timestamp = timestamp()
      ip_address             = server.ip_address
      status                 = "configured"
    }
  }
}
