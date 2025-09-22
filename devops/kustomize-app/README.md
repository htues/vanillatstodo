# Kustomize +```

kustomize-app/
├── README.md # This file
├── base/ # Base Kustomization using Helm chart
│ ├── kustomization.yaml # Base Kustomize config
│ └── values.yaml # Base Helm values
└── overlays/ # Environment-specific configurations
├── experimental/ # Development environment
│ └── kustomization.yaml
├── staging/ # Staging environment  
 │ └── kustomization.yaml
└── production/ # Production environment
└── kustomization.yamlConfiguration

This directory contains Kustomize configurations for deploying the Vanillatstodo application using a GitOps-ready architecture that combines Kustomize and Helm.

## Architecture Benefits

🎯 **Problem Solved**: Eliminates values file duplication while maintaining Helm's templating power  
🚀 **GitOps Ready**: Designed for ArgoCD and modern GitOps workflows  
🔧 **Environment Management**: Clean separation of environment-specific configurations  
📦 **Helm Integration**: Leverages existing Helm charts without modification

## Directory Structure

```
kustomize/
├── README.md              # This file
├── base/                  # Base Kustomization using Helm chart
│   ├── kustomization.yaml # Base Kustomize config
│   └── values.yaml        # Base Helm values
└── overlays/              # Environment-specific configurations
    ├── experimental/      # Development environment
    │   └── kustomization.yaml
    ├── staging/           # Staging environment
    │   └── kustomization.yaml
    └── production/        # Production environment
        └── kustomization.yaml
```

## How It Works

1. **Base Layer**: Defines the core Helm chart configuration in `base/`
2. **Overlays**: Environment-specific patches in `overlays/*/`
3. **Helm Integration**: Kustomize calls Helm to render templates, then applies patches
4. **GitOps**: ArgoCD watches for changes and deploys automatically

## Deployment Commands

### Using kubectl + Kustomize

```bash
# Deploy to experimental environment
kubectl apply -k overlays/experimental

# Deploy to staging environment
kubectl apply -k overlays/staging

# Deploy to production environment
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
# Validate all overlays
kubectl kustomize overlays/experimental | kubectl apply --dry-run=client -f -
kubectl kustomize overlays/staging | kubectl apply --dry-run=client -f -
kubectl kustomize overlays/production | kubectl apply --dry-run=client -f -
```

## Environment Configurations

### Experimental (Development)

- **Namespace**: `vanillatstodo-exp`
- **Replicas**: 2
- **Resources**: Minimal for development
- **Health Checks**: Disabled for faster iteration

### Staging

- **Namespace**: `vanillatstodo-staging`
- **Replicas**: 2
- **Resources**: Staging-appropriate allocation
- **Health Checks**: Enabled

### Production

- **Namespace**: `vanillatstodo-prod`
- **Replicas**: 3
- **Resources**: Production-grade allocation
- **Health Checks**: Enabled with strict settings

## GitOps Integration

### ArgoCD Setup

Each environment can be configured as a separate ArgoCD Application:

```yaml
# production-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: vanillatstodo-production
spec:
  project: default
  source:
    repoURL: https://github.com/your-org/vanillatstodo
    path: devops/kustomize-app/overlays/production
    targetRevision: main
  destination:
    server: https://kubernetes.default.svc
    namespace: vanillatstodo-prod
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### CI/CD Integration

GitHub Actions workflows automatically:

1. **Build**: Create Docker images with proper tags
2. **Update**: Modify Kustomize overlays with new image tags
3. **Commit**: Push changes to trigger GitOps deployment
4. **Deploy**: ArgoCD detects changes and deploys automatically

## Best Practices

### Configuration Management

- ✅ Environment-specific configs in overlays only
- ✅ Common configurations in base layer
- ✅ No hardcoded values, use Kustomize patches
- ✅ Consistent naming conventions across environments

### Security

- ✅ Separate namespaces for environment isolation
- ✅ RBAC configurations per environment
- ✅ Secret management through sealed-secrets or external-secrets
- ✅ Network policies for traffic isolation

### Monitoring

- ✅ Environment-specific monitoring configurations
- ✅ Prometheus scraping rules per overlay
- ✅ Grafana dashboards for each environment
- ✅ Alerting rules tailored to environment criticality

## Troubleshooting

### Common Issues

1. **Helm not found**: Ensure Helm 3.x is installed
2. **Permission denied**: Check RBAC permissions for target namespaces
3. **Image pull errors**: Verify image tags in overlay configurations
4. **Resource conflicts**: Ensure each environment uses different namespaces

### Debugging Commands

```bash
# Check what Kustomize generates
kubectl kustomize overlays/experimental

# Validate generated YAML
kubectl kustomize overlays/experimental | kubectl apply --dry-run=client -f -

# Check deployment status
kubectl get all -n vanillatstodo-exp

# View events for troubleshooting
kubectl get events -n vanillatstodo-exp --sort-by=.metadata.creationTimestamp
```

## Migration from Values Files

This Kustomize setup replaces the previous multiple values files approach:

```bash
# Old approach (deprecated)
helm install app ./helm-chart -f values-production.yaml

# New approach (current)
kubectl apply -k overlays/production
```

The new approach provides:

- Better GitOps integration
- Reduced configuration duplication
- Cleaner environment separation
- Enhanced security through Git-based workflows
