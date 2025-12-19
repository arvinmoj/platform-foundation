# PXE Server Module
# Configures PXE/TFTP boot infrastructure for automated OS installation

locals {
  # Determine PXE server IP (use provided or extract from network config)
  pxe_server_ip = var.pxe_server_ip != "" ? var.pxe_server_ip : cidrhost(var.network_config.subnet_cidr, 100)

  # Boot menu entries
  boot_menu_entries = {
    for name, server in var.servers :
    name => {
      hostname    = name
      ip_address  = server.ip_address
      mac_address = server.mac_address
      role        = server.role
    }
  }

  # Ubuntu kernel and initrd URLs
  ubuntu_kernel_url  = "http://${local.pxe_server_ip}/ubuntu/${var.ubuntu_version}/vmlinuz"
  ubuntu_initrd_url  = "http://${local.pxe_server_ip}/ubuntu/${var.ubuntu_version}/initrd"
}

# Generate iPXE boot configuration for each server
resource "local_file" "ipxe_boot_config" {
  for_each = var.servers

  content = templatefile("${path.module}/templates/ipxe-boot.tftpl", {
    autoinstall_url = "http://${local.pxe_server_ip}/autoinstall/${each.key}.yaml"
    hostname        = each.key
    initrd_url      = local.ubuntu_initrd_url
    kernel_url      = local.ubuntu_kernel_url
  })
  
  filename = "${var.tftp_directory}/boot-${each.value.mac_address}.ipxe"

  file_permission = "0644"
}

# Generate Ubuntu autoinstall configuration for each server
resource "local_file" "autoinstall_config" {
  for_each = var.servers

  content = templatefile("${path.module}/templates/autoinstall.yaml.tftpl", {
    disk_layout   = each.value.role == "control-plane" ? "lvm" : "lvm"
    dns_servers   = [var.network_config.gateway, "8.8.8.8"]
    gateway       = var.network_config.gateway
    hostname      = each.key
    ip_address    = each.value.ip_address
    packages      = ["docker.io", "nfs-common", "ipmitool", "net-tools", "curl", "wget"]
    role          = each.value.role
    ssh_keys      = var.ssh_public_keys
    storage_disks = each.value.storage_disks
    subnet_cidr   = var.network_config.subnet_cidr
  })
  
  filename = "${var.http_directory}/autoinstall/${each.key}.yaml"

  file_permission = "0644"
}

# Generate main iPXE menu
resource "local_file" "ipxe_menu" {
  content = templatefile("${path.module}/templates/menu.ipxe.tftpl", {
    entries       = local.boot_menu_entries
    pxe_server_ip = local.pxe_server_ip
  })
  
  filename = "${var.tftp_directory}/menu.ipxe"

  file_permission = "0644"
}

# Generate PXE server setup script
resource "local_file" "pxe_setup_script" {
  content = templatefile("${path.module}/scripts/setup-pxe-server.sh.tftpl", {
    http_directory = var.http_directory
    pxe_server_ip  = local.pxe_server_ip
    tftp_directory = var.tftp_directory
    ubuntu_version = var.ubuntu_version
  })
  
  filename = "${path.module}/../../scripts/provisioning/setup-pxe-server-${var.cluster_name}.sh"

  file_permission = "0755"
}

# Generate DHCP configuration for reference
resource "local_file" "dhcp_config" {
  content = templatefile("${path.module}/templates/dhcpd.conf.tftpl", {
    gateway        = var.network_config.gateway
    pxe_server_ip  = local.pxe_server_ip
    servers        = var.servers
    subnet_cidr    = var.network_config.subnet_cidr
  })
  
  filename = "${path.module}/../../pxe/dhcpd-${var.cluster_name}.conf"

  file_permission = "0644"
}

# Generate dnsmasq configuration (alternative to ISC DHCP)
resource "local_file" "dnsmasq_config" {
  content = templatefile("${path.module}/templates/dnsmasq.conf.tftpl", {
    gateway       = var.network_config.gateway
    pxe_server_ip = local.pxe_server_ip
    servers       = var.servers
    subnet_cidr   = var.network_config.subnet_cidr
    tftp_directory = var.tftp_directory
  })
  
  filename = "${path.module}/../../pxe/dnsmasq-${var.cluster_name}.conf"

  file_permission = "0644"
}
