output "boot_configurations" {
  description = "Generated PXE boot configurations"
  value = {
    for name, server in var.servers :
    name => {
      autoinstall_url = "http://${local.pxe_server_ip}/autoinstall/${name}.yaml"
      mac_address     = server.mac_address
      pxe_menu_entry  = "${name}-${server.role}"
    }
  }
}

output "http_directory" {
  description = "HTTP directory path"
  value       = var.http_directory
}

output "pxe_server_ip" {
  description = "IP address of the PXE server"
  value       = local.pxe_server_ip
}

output "tftp_directory" {
  description = "TFTP directory path"
  value       = var.tftp_directory
}

output "ubuntu_version" {
  description = "Ubuntu version configured for installation"
  value       = var.ubuntu_version
}
