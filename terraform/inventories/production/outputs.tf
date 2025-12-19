output "cluster_endpoint" {
  description = "Kubernetes API endpoint"
  value       = module.platform.cluster_endpoint
}

output "cluster_name" {
  description = "Cluster name"
  value       = module.platform.cluster_name
}

output "control_plane_nodes" {
  description = "Control plane nodes"
  value       = module.platform.control_plane_nodes
}

output "worker_nodes" {
  description = "Worker nodes"
  value       = module.platform.worker_nodes
}
