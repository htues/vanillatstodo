# Vanillatstodo Helm Chart

This Helm chart replaces the legacy `devops/k8s/` directory for deploying the Vanillatstodo application.

## 🔒 Security-First Deployment Approach

**⚠️ No shell scripts for security reasons**  
All production deployments are managed exclusively through GitHub Actions for enhanced security, auditability, and consistency.

## Migration from kubectl to Helm

### Old Way (deprecated)

```bash
kubectl apply -f devops/k8s/
```

### New Way (GitHub Actions managed)

**Production & Staging:** Deployments are automatically triggered through GitHub Actions workflows.

**Local Development Only:**

```bash
# For development/testing purposes only
helm upgrade --install vanillatstodo-exp ./devops/helm-chart -f ./devops/helm-chart/values-experimental.yaml
```

**Alternative for team development:**

```bash
# Using Makefile (safer than shell scripts)
make deploy-experimental
make deploy-staging
make deploy-production
```

## Chart Structure

```
devops/helm-chart/
├── Chart.yaml                    # Chart metadata
├── values.yaml                   # Default values (production baseline)
├── values-experimental.yaml      # Development/experimental environment
├── values-staging.yaml          # Staging environment
├── values-production.yaml       # Production environment
└── templates/
    ├── deployment.yaml          # Application deployment
    └── service.yaml            # LoadBalancer service
```

## Environment-Specific Deployments

Each environment has its own values file with appropriate resource allocations:

- **Experimental**: 2 replicas, 100m-200m CPU, health checks disabled
- **Staging**: 2 replicas, 150m-300m CPU, health checks disabled
- **Production**: 3 replicas, 200m-500m CPU, health checks enabled

## Useful Commands

```bash
# Dry run to see what would be deployed
helm template vanillatstodo ./devops/helm-chart -f ./devops/helm-chart/values-experimental.yaml

# Validate chart
helm lint ./devops/helm-chart

# Check deployment status
helm status vanillatstodo-exp

# Rollback deployment
helm rollback vanillatstodo-exp 1

# Uninstall
helm uninstall vanillatstodo-exp
```

## Multi-Tenant Deployment

For SaaS deployments, you can create client-specific values files:

```bash
# Create client-specific values
cp values-production.yaml values-client1.yaml

# Deploy for specific client (via GitHub Actions only)
# Manual deployment for development only:
helm upgrade --install client1-todo ./devops/helm-chart -f ./devops/helm-chart/values-client1.yaml
```

## 🔒 Security Best Practices

### Production Deployments

- ✅ **GitHub Actions Only**: All production deployments managed via CI/CD
- ✅ **No Executable Scripts**: No shell scripts in production repositories
- ✅ **Audit Trail**: All deployments logged and tracked
- ✅ **Access Control**: Deployments require proper GitHub permissions

### Development Guidelines

- 🔍 **Local Testing**: Use Helm commands directly for development
- 📝 **Documentation**: All commands documented instead of scripted
- 🛡️ **Principle of Least Privilege**: Minimal permissions for development environments
- 🔄 **GitOps Ready**: Prepared for ArgoCD/FluxCD migration
