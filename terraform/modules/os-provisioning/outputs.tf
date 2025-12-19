output "provisioned_servers" {
  description = "List of provisioned servers"
  value = [
    for name in keys(var.servers) : name
  ]
}

output "provisioning_status" {
  description = "Provisioning status for each server"
  value = {
    for name, server in var.servers :
    name => {
      ip_address = server.ip_address
      status     = "configured"
    }
  }
}
