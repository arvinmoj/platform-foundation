# Operations Guide

## Daily Operations

### Cluster Health Monitoring

```bash
# Check cluster status
./metalctl health

# View node status
kubectl get nodes -o wide

# Check pod health
kubectl get pods --all-namespaces

# View cluster events
kubectl get events --all-namespaces --sort-by='.lastTimestamp'
```

### Hardware Monitoring

```bash
# Run hardware health check
./metalctl health

# Check IPMI sensors
for node in k8s-master-01 k8s-worker-01; do
  ipmitool -I lanplus -H $node-bmc -U ADMIN -P password sensor
done

# Monitor disk health
kubectl exec -n rook-ceph deploy/rook-ceph-tools -- ceph health detail
```

### Log Management

```bash
# View kubelet logs
ssh ubuntu@k8s-master-01 'sudo journalctl -u kubelet -f'

# View container logs
kubectl logs -n kube-system <pod-name>

# View all logs for a deployment
kubectl logs -n default deployment/my-app --all-containers=true
```

## Maintenance Tasks

### Node Maintenance

#### Drain a Node
```bash
# Safely evict all pods
kubectl drain k8s-worker-01 --ignore-daemonsets --delete-emptydir-data

# Perform maintenance...

# Mark node as schedulable again
kubectl uncordon k8s-worker-01
```

#### Reboot a Node
```bash
# Drain the node first
kubectl drain k8s-worker-01 --ignore-daemonsets

# Reboot via IPMI
./metalctl power --state reset --nodes k8s-worker-01

# Or SSH
ssh ubuntu@k8s-worker-01 'sudo reboot'

# Wait for node to come back
kubectl wait --for=condition=Ready node/k8s-worker-01 --timeout=10m

# Uncordon
kubectl uncordon k8s-worker-01
```

### Kubernetes Upgrades

#### Control Plane Upgrade
```bash
# Upgrade first master
kubectl drain k8s-master-01 --ignore-daemonsets
ssh ubuntu@k8s-master-01 'sudo kubeadm upgrade apply v1.29.0'
kubectl uncordon k8s-master-01

# Upgrade additional masters
for node in k8s-master-02 k8s-master-03; do
  kubectl drain $node --ignore-daemonsets
  ssh ubuntu@$node 'sudo kubeadm upgrade node'
  kubectl uncordon $node
done
```

#### Worker Upgrade
```bash
for node in k8s-worker-{01..03}; do
  kubectl drain $node --ignore-daemonsets --delete-emptydir-data
  ssh ubuntu@$node 'sudo kubeadm upgrade node'
  kubectl uncordon $node
done
```

### Storage Management

#### Ceph Operations
```bash
# Check Ceph status
kubectl exec -n rook-ceph deploy/rook-ceph-tools -- ceph status

# Check OSD status
kubectl exec -n rook-ceph deploy/rook-ceph-tools -- ceph osd status

# Check pool usage
kubectl exec -n rook-ceph deploy/rook-ceph-tools -- ceph df

# Add new OSD
kubectl exec -n rook-ceph deploy/rook-ceph-tools -- ceph osd create
```

#### Volume Management
```bash
# List PVs
kubectl get pv

# List PVCs
kubectl get pvc --all-namespaces

# Expand a PVC (if storage class supports it)
kubectl patch pvc my-pvc -p '{"spec":{"resources":{"requests":{"storage":"200Gi"}}}}'
```

## Backup and Recovery

### etcd Backup
```bash
# Backup etcd
ETCDCTL_API=3 etcdctl \
  --endpoints=https://192.168.1.10:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /backup/etcd-snapshot-$(date +%Y%m%d-%H%M%S).db
```

### Application Backup (with Velero)
```bash
# Backup a namespace
velero backup create my-backup --include-namespaces=production

# List backups
velero backup get

# Restore from backup
velero restore create --from-backup my-backup
```

## Troubleshooting

### Pod Issues

#### Pod Stuck in Pending
```bash
# Check events
kubectl describe pod <pod-name>

# Check node resources
kubectl describe nodes

# Check PVC status (if using volumes)
kubectl get pvc
```

#### Pod CrashLoopBackOff
```bash
# Check logs
kubectl logs <pod-name> --previous

# Check resource limits
kubectl describe pod <pod-name>

# Check liveness/readiness probes
kubectl get pod <pod-name> -o yaml | grep -A 10 livenessProbe
```

### Network Issues

#### Pod-to-Pod Communication
```bash
# Test from one pod to another
kubectl exec -it <pod-1> -- ping <pod-2-ip>

# Check network policies
kubectl get networkpolicies --all-namespaces

# Check CNI logs
kubectl logs -n kube-system -l k8s-app=calico-node
```

#### External Access
```bash
# Check service endpoints
kubectl get endpoints

# Check ingress
kubectl get ingress --all-namespaces

# Check MetalLB
kubectl get configmap -n metallb-system
kubectl logs -n metallb-system -l app=metallb
```

### Storage Issues

#### PVC Not Binding
```bash
# Check PVC status
kubectl describe pvc <pvc-name>

# Check storage class
kubectl get storageclass

# Check Ceph status
kubectl exec -n rook-ceph deploy/rook-ceph-tools -- ceph health detail
```

#### Disk Full
```bash
# Check node disk usage
kubectl get nodes
kubectl describe node <node-name>

# Check Ceph usage
kubectl exec -n rook-ceph deploy/rook-ceph-tools -- ceph df

# Clean up unused volumes
kubectl delete pvc <unused-pvc>
```

## Performance Tuning

### Node Tuning
```bash
# Increase file descriptors
echo "fs.file-max = 2097152" | sudo tee -a /etc/sysctl.conf

# Network tuning
echo "net.core.rmem_max = 134217728" | sudo tee -a /etc/sysctl.conf
echo "net.core.wmem_max = 134217728" | sudo tee -a /etc/sysctl.conf

# Apply changes
sudo sysctl -p
```

### Storage Tuning
```bash
# Adjust Ceph OSD settings
kubectl exec -n rook-ceph deploy/rook-ceph-tools -- \
  ceph config set osd osd_memory_target 4294967296
```

## Security Operations

### Certificate Management
```bash
# Check certificate expiration
kubeadm certs check-expiration

# Renew certificates
kubeadm certs renew all
```

### RBAC Management
```bash
# Create service account
kubectl create serviceaccount my-sa

# Create role binding
kubectl create rolebinding my-binding \
  --role=my-role \
  --serviceaccount=default:my-sa
```

## Monitoring and Alerting

### Prometheus Queries
```promql
# Node CPU usage
100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Node memory usage
100 * (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes))

# Pod restart count
kube_pod_container_status_restarts_total > 5
```

### Alert Examples
```yaml
# High CPU alert
- alert: HighCPUUsage
  expr: node_cpu_seconds_total{mode="idle"} < 20
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "High CPU usage on {{ $labels.instance }}"
```

## Emergency Procedures

### Cluster Unresponsive
1. Check control plane nodes
2. Verify etcd health
3. Check network connectivity
4. Review recent changes
5. Consider restoring from backup

### Data Loss Prevention
1. Regular etcd backups (automated)
2. Application-level backups (Velero)
3. Configuration version control (Git)
4. Disaster recovery plan documented

## Useful Commands Reference

```bash
# Get cluster info
kubectl cluster-info
kubectl version

# Resource usage
kubectl top nodes
kubectl top pods --all-namespaces

# Debugging
kubectl debug node/<node-name> -it --image=ubuntu
kubectl run -it --rm debug --image=busybox --restart=Never -- sh

# Port forwarding
kubectl port-forward svc/my-service 8080:80

# Execute in pod
kubectl exec -it <pod-name> -- /bin/bash

# Copy files
kubectl cp <local-file> <pod-name>:/path/to/destination
```
