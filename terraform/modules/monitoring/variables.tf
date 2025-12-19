variable "bmc_credentials" { type = any; sensitive = true }
variable "cluster_name" { type = string }
variable "monitoring_enabled" { type = bool }
variable "servers" { type = any }
variable "tags" { type = map(string); default = {} }
