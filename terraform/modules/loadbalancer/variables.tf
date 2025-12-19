variable "cluster_name" { type = string }
variable "control_plane_nodes" { type = any }
variable "control_plane_vip" { type = string }
variable "metallb_address_pool" { type = list(string) }
variable "tags" { type = map(string); default = {} }
