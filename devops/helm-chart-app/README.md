# Vanillats```

devops/
├── helm-chart-app/ # Helm chart (this directory)
│ ├── Chart.yaml # Chart metadata
│ ├── values.yaml # Base values
│ └── templates/ # Kubernetes manifests
└── kustomize-app/ # Kustomize configuration
├── base/ # Base Kustomization using this Helm chart
└── overlays/ # Environment-specific configurations
├── experimental/ # Development environment
├── staging/ # Staging environment  
 └── production/ # Production environmentart

This Helm chart is part of a GitOps-ready Kustomize + Helm architecture for deploying the Vanillatstodo application.

## 🚀 GitOps-Ready Architecture

**✨ Kustomize + Helm Integration**  
This chart works seamlessly with Kustomize overlays for environment-specific configurations, eliminating values file duplication and enabling true GitOps workflows.

## Architecture Overview

```
devops/
├── helm-chart-app/           # Helm chart (this directory)
│   ├── Chart.yaml           # Chart metadata
│   ├── values.yaml         # Base values
│   └── templates/          # Kubernetes manifests
└── kustomize/              # Kustomize configuration
    ├── base/               # Base Kustomization using this Helm chart
    └── overlays/           # Environment-specific configurations
        ├── experimental/   # Development environment
        ├── staging/        # Staging environment
        └── production/     # Production environment
```

## 🔒 Security-First Deployment Approach

**⚠️ No shell scripts for security reasons**  
All production deployments are managed exclusively through GitHub Actions and Kustomize for enhanced security, auditability, and consistency.

## Migration from Multiple Values Files to Kustomize

### Old Way (deprecated)

```bash
# Multiple values files approach (deprecated)
helm upgrade --install vanillatstodo-exp ./devops/helm-chart-app -f ./devops/helm-chart-app/values-experimental.yaml
helm upgrade --install vanillatstodo-staging ./devops/helm-chart-app -f ./devops/helm-chart-app/values-staging.yaml
helm upgrade --install vanillatstodo-prod ./devops/helm-chart-app -f ./devops/helm-chart-app/values-production.yaml
```

### New Way (Kustomize + Helm)

**Production & Staging:** Deployments are automatically triggered through GitHub Actions workflows using Kustomize.

````bash
# Deploy using Kustomize overlays (recommended)
kubectl apply -k ../../kustomize-app/overlays/experimental
kubectl apply -k ../../kustomize-app/overlays/staging
kubectl apply -k ../../kustomize-app/overlays/production
```**Local Development:**

```bash
# For development/testing purposes only
helm upgrade --install vanillatstodo-dev ./devops/helm-chart-app
````

## Environment Configurations

Each environment is configured through Kustomize overlays that patch the base Helm chart:

- **Experimental**: 2 replicas, minimal resources for development
- **Staging**: 2 replicas, staging-appropriate resources
- **Production**: 3 replicas, production-grade resources and health checks

All environment-specific values are managed in `../kustomize-app/overlays/*/kustomization.yaml` files.

## Useful Commands

```bash
# Preview what Kustomize will deploy
kubectl kustomize ../kustomize-app/overlays/experimental

# Validate the Helm chart
helm lint ./

# Test the chart with different values
helm template vanillatstodo ./ --values values.yaml

# Check current deployments
kubectl get all -l app.kubernetes.io/name=vanillatstodo

# Rollback using Helm (if deployed via Helm)
helm rollback vanillatstodo-dev 1

# Remove deployment
kubectl delete -k ../kustomize-app/overlays/experimental
```

## GitOps Integration

### ArgoCD Application

This chart is designed to work seamlessly with ArgoCD:

```yaml
# Example ArgoCD Application
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: vanillatstodo-production
spec:
  source:
    repoURL: https://github.com/your-org/vanillatstodo
    path: devops/kustomize-app/overlays/production
    targetRevision: main
  destination:
    server: https://kubernetes.default.svc
    namespace: vanillatstodo-prod
```

### Continuous Deployment

GitHub Actions workflows automatically:

1. Build and push Docker images
2. Update Kustomize configurations with new image tags
3. ArgoCD detects changes and deploys automatically

## 🔒 Security Best Practices

### Production Deployments

- ✅ **GitOps Workflow**: All deployments managed via Kustomize + ArgoCD
- ✅ **No Executable Scripts**: No shell scripts in production repositories
- ✅ **Audit Trail**: All deployments logged and tracked through Git
- ✅ **Access Control**: Deployments require proper Git and Kubernetes permissions
- ✅ **Environment Isolation**: Clear separation between environments using namespaces
- ✅ **Immutable Deployments**: Configuration changes tracked in Git history

### Development Guidelines

- 🔍 **Local Testing**: Use Helm commands directly for development
- 📝 **Documentation**: All commands documented instead of scripted
- 🛡️ **Principle of Least Privilege**: Minimal permissions for development environments
- 🔄 **GitOps Ready**: Prepared for ArgoCD/FluxCD migration
