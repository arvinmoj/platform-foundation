variable "cluster_name" { type = string }
variable "servers" { type = any }
variable "storage_config" { type = any }
variable "tags" { type = map(string); default = {} }
