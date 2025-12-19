variable "cluster_name" { type = string }
variable "network_config" { type = any }
variable "servers" { type = any }
variable "tags" { type = map(string); default = {} }
