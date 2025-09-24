# ⚠️ DEPRECATED: This directory is deprecated

**This directory has been replaced by the Helm chart at `../helm-chart-app/`**

## Migration Guide

### Old deployment method (this directory):

```bash
kubectl apply -f devops/k8s/
```

### New deployment method (recommended):

```bash
# Experimental environment
helm upgrade --install vanillatstodo-exp ./devops/helm-chart-app -f ./devops/helm-chart-app/values-experimental.yaml

# Staging environment
helm upgrade --install vanillatstodo-staging ./devops/helm-chart-app -f ./devops/helm-chart-app/values-staging.yaml

# Production environment
helm upgrade --install vanillatstodo-prod ./devops/helm-chart-app -f ./devops/helm-chart-app/values-production.yaml
```

## Why Helm?

- **Parameterization**: Single chart, multiple environments
- **Version management**: Easy rollbacks and upgrades
- **Multi-tenant ready**: Perfect for SaaS deployments
- **Industry standard**: Used by most production Kubernetes deployments

## Files in this directory:

- `vanillatstodo_deployment.yml` - Legacy deployment (use Helm instead)
- `vanillatstodo_service.yml` - Legacy service (use Helm instead)

These files are kept for reference but should not be used for new deployments.

**Please use the Helm chart at `../helm-chart-app/` for all new deployments.**
