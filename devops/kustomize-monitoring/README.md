# Kustomize + Helm Monitoring Configuration

This directory contains Kustomize configurations for deploying the monitoring stack using a GitOps-ready architecture that combines Kustomize and Helm.

## Architecture Benefits

🎯 **Unified Approach**: Same Kustomize + Helm pattern as the application deployment  
📊 **Environment-Specific Monitoring**: Tailored monitoring configurations per environment  
🔧 **Maintainable**: Single source of truth with environment-specific patches  
🚀 **GitOps Ready**: Perfect for ArgoCD and modern GitOps workflows  
📦 **Helm Integration**: Leverages existing monitoring Helm charts without modification

## Directory Structure

```
kustomize-monitoring/
├── README.md              # This file
├── base/                  # Base Kustomization using Helm chart
│   ├── kustomization.yaml # Base Kustomize config
│   └── values.yaml        # Base Helm values
└── overlays/              # Environment-specific configurations
    ├── experimental/      # Development monitoring
    │   └── kustomization.yaml
    ├── staging/           # Staging monitoring
    │   └── kustomization.yaml
    └── production/        # Production monitoring
        ├── kustomization.yaml
        └── resource-quota.yaml
```

## How It Works

1. **Base Layer**: Defines the core monitoring Helm chart configuration in `base/`
2. **Overlays**: Environment-specific monitoring patches in `overlays/*/`
3. **Helm Integration**: Kustomize calls Helm to render monitoring templates, then applies patches
4. **GitOps**: ArgoCD watches for changes and deploys monitoring automatically

## Monitoring Stack Components

### Core Components

- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards
- **AlertManager**: Alert routing and management
- **Node Exporter**: Node-level metrics
- **Kube State Metrics**: Kubernetes cluster metrics

### ServiceMonitors

- Application metrics scraping configuration
- Environment-specific scraping intervals
- Custom metric endpoints

## Deployment Commands

### Using kubectl + Kustomize

```bash
# Deploy monitoring to experimental environment
kubectl apply -k overlays/experimental

# Deploy monitoring to staging environment
kubectl apply -k overlays/staging

# Deploy monitoring to production environment
kubectl apply -k overlays/production
```

### Preview Changes

```bash
# See what would be deployed to experimental
kubectl kustomize overlays/experimental

# See what would be deployed to staging
kubectl kustomize overlays/staging

# See what would be deployed to production
kubectl kustomize overlays/production
```

### Validation

```bash
# Validate all monitoring overlays
kubectl kustomize overlays/experimental | kubectl apply --dry-run=client -f -
kubectl kustomize overlays/staging | kubectl apply --dry-run=client -f -
kubectl kustomize overlays/production | kubectl apply --dry-run=client -f -
```

## Environment Configurations

### Experimental (Development)

- **Namespace**: `monitoring-exp`
- **Retention**: 7 days
- **Storage**: 2GB
- **Resources**: Minimal for development
- **Metrics Interval**: 60s
- **Alerting**: Disabled
- **Ingress**: Disabled

### Staging

- **Namespace**: `monitoring-staging`
- **Retention**: 15 days
- **Storage**: 5GB
- **Resources**: Staging-appropriate allocation
- **Metrics Interval**: 30s
- **Alerting**: Enabled
- **Ingress**: Enabled (staging domains)

### Production

- **Namespace**: `monitoring-prod`
- **Retention**: 30 days
- **Storage**: 10GB (Prometheus) + 20GB (Grafana)
- **Resources**: Production-grade allocation with HA
- **Metrics Interval**: 15s
- **Alerting**: Enabled with full configuration
- **Ingress**: Enabled (production domains)
- **Resource Quotas**: Enforced limits and requests

## GitOps Integration

### ArgoCD Setup

Each monitoring environment can be configured as a separate ArgoCD Application:

```yaml
# monitoring-production-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: monitoring-production
spec:
  project: default
  source:
    repoURL: https://github.com/your-org/vanillatstodo
    path: devops/kustomize-monitoring/overlays/production
    targetRevision: main
  destination:
    server: https://kubernetes.default.svc
    namespace: monitoring-prod
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

### CI/CD Integration

Monitoring deployments can be automated through GitHub Actions:

1. **Config Changes**: Modify Kustomize overlays for monitoring updates
2. **Validation**: Automatically validate monitoring configurations
3. **Deployment**: ArgoCD detects changes and deploys monitoring stack
4. **Health Checks**: Verify monitoring stack health post-deployment

## Monitoring Configuration Details

### Prometheus Configuration

- **Retention Policies**: Environment-specific data retention
- **Storage**: Persistent volumes with appropriate sizing
- **Scraping**: Custom ServiceMonitor configurations
- **Resource Limits**: CPU and memory limits per environment

### Grafana Configuration

- **Dashboards**: Environment-specific dashboard configurations
- **Data Sources**: Automatic Prometheus connection
- **Authentication**: Environment-specific admin credentials
- **Persistence**: Dashboard and configuration persistence

### AlertManager Configuration

- **Routing**: Environment-specific alert routing
- **Integrations**: Slack, email, webhook integrations
- **Severity Levels**: Different alert thresholds per environment
- **Inhibition Rules**: Prevent alert flooding

## Best Practices

### Configuration Management

- ✅ Environment-specific configs in overlays only
- ✅ Common monitoring configurations in base layer
- ✅ No hardcoded values, use Kustomize patches
- ✅ Consistent labeling for monitoring resources

### Security

- ✅ Separate namespaces for monitoring isolation
- ✅ RBAC configurations per environment
- ✅ Secret management for authentication
- ✅ Network policies for monitoring traffic

### Alerting

- ✅ Environment-appropriate alert thresholds
- ✅ Escalation policies per environment criticality
- ✅ Alert routing based on environment and severity
- ✅ Runbook automation for common issues

### Resource Management

- ✅ Resource quotas in production
- ✅ Appropriate resource requests and limits
- ✅ Storage class optimization per environment
- ✅ Horizontal Pod Autoscaling where applicable

## Troubleshooting

### Common Issues

1. **Storage Issues**: Check PVC provisioning and storage classes
2. **Resource Limits**: Verify resource quotas and limits
3. **Service Discovery**: Ensure ServiceMonitor configurations are correct
4. **Networking**: Verify ingress and service configurations

### Debugging Commands

```bash
# Check monitoring stack status
kubectl get all -n monitoring-exp

# Check Prometheus targets
kubectl port-forward -n monitoring-exp svc/prometheus 9090:9090

# Check Grafana access
kubectl port-forward -n monitoring-exp svc/grafana 3000:80

# View monitoring events
kubectl get events -n monitoring-exp --sort-by=.metadata.creationTimestamp

# Check storage usage
kubectl get pvc -n monitoring-exp
```

### Logs and Metrics

```bash
# Prometheus logs
kubectl logs -n monitoring-exp deployment/prometheus

# Grafana logs
kubectl logs -n monitoring-exp deployment/grafana

# AlertManager logs
kubectl logs -n monitoring-exp deployment/alertmanager
```

## Migration from Values Files

This Kustomize setup replaces the previous multiple values files approach:

```bash
# Old approach (deprecated)
helm install monitoring ./helm-chart-monitoring -f values-production.yaml

# New approach (current)
kubectl apply -k overlays/production
```

### Migration Benefits

- Better GitOps integration
- Reduced configuration duplication
- Environment-specific monitoring tuning
- Enhanced security through Git-based workflows
- Unified deployment approach with application stack

## Integration with Application Monitoring

### ServiceMonitor Configuration

The monitoring stack automatically discovers and scrapes metrics from:

- Application pods with appropriate annotations
- Kubernetes system components
- Custom metric endpoints defined in ServiceMonitors

### Dashboard Integration

- Pre-configured dashboards for application metrics
- Environment-specific alerting rules
- Automated dashboard provisioning through GitOps

### Multi-Environment Visibility

- Centralized monitoring view across environments
- Environment-specific alert routing
- Resource usage tracking per environment
