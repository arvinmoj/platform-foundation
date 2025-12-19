variable "cluster_name" { type = string }
variable "control_plane_nodes" { type = any }
variable "control_plane_vip" { type = string }
variable "kubernetes_version" { type = string }
variable "network_config" { type = any }
variable "tags" { type = map(string); default = {} }
variable "worker_nodes" { type = any }
