# Monitoring Stack for VanillaTsTodo

This monitoring stack provides comprehensive observability for your Kubernetes applications using Prometheus and Grafana.

## 🚀 Quick Start

### 1. Deploy Infrastructure First

```bash
# Deploy EKS cluster if not already deployed
./devops/scripts/infra-manager.sh deploy
```

### 2. Deploy Application

```bash
# Deploy your application first
# Use GitHub Actions: deploy_codeto_aws.yml
```

### 3. Deploy Monitoring Stack

```bash
# Use GitHub Actions workflow: deploy_monitoring_aws.yml
# Or manually with Helm:

# Add repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Create namespace
kubectl create namespace monitoring

# Deploy monitoring stack
cd devops/helm-chart-monitoring
helm dependency update
helm upgrade --install vanillatstodo-monitoring-experimental . \
  --namespace monitoring \
  -f values-experimental.yaml \
  --wait
```

## 📊 Access Monitoring

### Grafana (Web UI)

- **Development/Experimental**: LoadBalancer URL (shown in workflow output)
- **Production**: LoadBalancer with SSL
- **Staging**: Port forward required

```bash
# Port forward for staging or local access
kubectl port-forward svc/vanillatstodo-monitoring-experimental-prometheus-stack-grafana 3000:80 --namespace monitoring
# Access: http://localhost:3000
```

### Prometheus (Metrics)

```bash
# Port forward for Prometheus
kubectl port-forward svc/vanillatstodo-monitoring-experimental-prometheus-stack-kube-prom-prometheus 9090:9090 --namespace monitoring
# Access: http://localhost:9090
```

### Default Credentials

- **Username**: admin
- **Password**: admin123 (change in production!)

## 📈 What's Included

### Monitoring Components

- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards
- **AlertManager**: Alert management and routing
- **Node Exporter**: System metrics
- **kube-state-metrics**: Kubernetes object metrics

### Pre-configured Dashboards

- Kubernetes Cluster Overview (ID: 7249)
- Node Exporter Dashboard (ID: 1860)
- Kubernetes Pods Monitoring (ID: 6417)

### Metrics Sources

- Kubernetes API Server
- Kubelet
- CoreDNS
- Controller Manager
- Scheduler
- ETCD
- Your application (if metrics endpoint is configured)

## 🎯 Environment Configurations

### Experimental/Development

- **Storage**: 5GB (3 days retention)
- **Resources**: Minimal (testing focused)
- **Access**: LoadBalancer
- **AlertManager**: Disabled

### Staging

- **Storage**: 10GB (7 days retention)
- **Resources**: Medium
- **Access**: ClusterIP (port-forward)
- **AlertManager**: Simplified

### Production

- **Storage**: 100GB (90 days retention)
- **Resources**: High performance
- **Access**: LoadBalancer with SSL
- **AlertManager**: Full email integration

## 🔧 Customization

### Adding Your Application Metrics

1. **Enable metrics in your application** (add metrics endpoint)
2. **Update your Helm chart** to expose metrics port
3. **Configure ServiceMonitor** (automatically created if enabled)

Example for Node.js/Express:

```javascript
const promClient = require("prom-client");
const register = new promClient.Registry();

// Metrics endpoint
app.get("/metrics", (req, res) => {
  res.set("Content-Type", register.contentType);
  res.end(register.metrics());
});
```

### Custom Dashboards

1. Access Grafana UI
2. Create new dashboard
3. Use Prometheus data source
4. Save and export JSON
5. Add to values files for persistence

### Custom Alerts

Edit the AlertManager configuration in values files:

```yaml
prometheus-stack:
  alertmanager:
    config:
      receivers:
        - name: "slack-alerts"
          slack_configs:
            - api_url: "YOUR_SLACK_WEBHOOK"
              channel: "#alerts"
```

## 🚨 Important Security Notes

### Production Checklist

- [ ] Change default Grafana password
- [ ] Configure SSL/TLS certificates
- [ ] Set up proper authentication (LDAP/OAuth)
- [ ] Configure network policies
- [ ] Set up backup for Grafana dashboards
- [ ] Configure proper AlertManager receivers

### Secrets Management

```bash
# Create secret for AlertManager SMTP
kubectl create secret generic alertmanager-smtp \
  --from-literal=username=alerts@company.com \
  --from-literal=password=smtp-password \
  --namespace monitoring
```

## 🛠️ Troubleshooting

### Common Issues

1. **Pods not starting**: Check storage class and resources

```bash
kubectl describe pod -n monitoring
kubectl get events -n monitoring --sort-by='.lastTimestamp'
```

2. **Metrics not appearing**: Check ServiceMonitor configuration

```bash
kubectl get servicemonitor -n monitoring
kubectl logs -n monitoring prometheus-stack-kube-prom-prometheus-0
```

3. **Grafana not accessible**: Check service type and LoadBalancer

```bash
kubectl get svc -n monitoring
kubectl describe svc vanillatstodo-monitoring-experimental-prometheus-stack-grafana -n monitoring
```

### Useful Commands

```bash
# Check all monitoring resources
kubectl get all -n monitoring

# Check persistent volumes
kubectl get pv,pvc -n monitoring

# Check Prometheus targets
kubectl port-forward svc/vanillatstodo-monitoring-experimental-prometheus-stack-kube-prom-prometheus 9090:9090 -n monitoring
# Go to: http://localhost:9090/targets

# Grafana admin password reset
kubectl get secret vanillatstodo-monitoring-experimental-prometheus-stack-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode
```

## 📚 Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
- [Grafana Dashboard Gallery](https://grafana.com/grafana/dashboards/)

## 🤝 Contributing

1. Test changes in experimental environment
2. Validate with staging
3. Deploy to production with proper change management
4. Update documentation for any configuration changes
