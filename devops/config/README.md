# Centralized Configuration Management

This document explains how we implement centralized configuration management across Kustomize + Helm deployments to avoid hardcoded values and enable reusability.

## Problem Statement

❌ **Before**: Hardcoded project names and values scattered across multiple files  
❌ **Issues**: Difficult to reuse, error-prone, maintenance overhead  
❌ **Example**: `vanillatstodo-monitoring-experimental` hardcoded everywhere

✅ **After**: Centralized configuration with dynamic value injection  
✅ **Benefits**: Reusable, maintainable, consistent naming  
✅ **Example**: Dynamic names using `namePrefix` + `nameSuffix`

## Architecture Overview

```
devops/
├── config/
│   └── global.env              # 🎯 Centralized configuration
├── kustomize-app/
│   ├── base/
│   │   └── kustomization.yaml  # Uses global.env
│   └── overlays/
│       ├── experimental/       # namePrefix + nameSuffix
│       ├── staging/            # namePrefix + nameSuffix
│       └── production/         # namePrefix + nameSuffix
└── kustomize-monitoring/
    ├── base/
    │   └── kustomization.yaml  # Uses global.env
    └── overlays/
        ├── experimental/       # namePrefix + nameSuffix
        ├── staging/            # namePrefix + nameSuffix
        └── production/         # namePrefix + nameSuffix
```

## Global Configuration File

**Location**: `devops/config/global.env`

```bash
# Project Information
PROJECT_NAME=vanillatstodo
ORGANIZATION=hftamayo
REPOSITORY=vanillatstodo

# Application Configuration
APP_NAME=vanillatstodo
APP_VERSION=0.1.0

# Monitoring Configuration
MONITORING_NAME=vanillatstodo-monitoring
MONITORING_VERSION=0.1.0

# Infrastructure Configuration
CLUSTER_NAME=vanillatstodo-cluster
AWS_REGION=us-east-2

# Container Registry
DOCKER_REGISTRY=hftamayo
DOCKER_REPOSITORY=hftamayo/vanillatstodo

# Domain Configuration
BASE_DOMAIN=vanillatstodo.local
PROD_DOMAIN=vanillatstodo.com
```

## Implementation Patterns

### 1. Base Kustomization Pattern

```yaml
# devops/kustomize-app/base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

metadata:
  name: app-base

# Load global configuration
configMapGenerator:
  - name: global-config
    envs:
      - ../../config/global.env
    options:
      disableNameSuffixHash: true

# Dynamic naming (overridden by overlays)
namePrefix: ""
nameSuffix: ""

# Common labels (extended by overlays)
commonLabels:
  app.kubernetes.io/component: application
  app.kubernetes.io/managed-by: kustomize
```

### 2. Environment Overlay Pattern

```yaml
# devops/kustomize-app/overlays/production/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

metadata:
  name: app-production

resources:
  - ../../base

# Dynamic naming using global config values
namePrefix: vanillatstodo- # From PROJECT_NAME
nameSuffix: -prod # Environment-specific

# Environment-specific namespace
namespace: vanillatstodo-prod

# Extended labels
commonLabels:
  environment: production
  app.kubernetes.io/name: vanillatstodo # From PROJECT_NAME
  app.kubernetes.io/part-of: vanillatstodo # From PROJECT_NAME
```

## Dynamic Naming Strategy

### Before (Hardcoded)

```yaml
metadata:
  name: vanillatstodo-monitoring-production

helmCharts:
  - name: vanillatstodo-app
    releaseName: vanillatstodo-production
```

### After (Dynamic)

```yaml
metadata:
  name: monitoring-production

namePrefix: vanillatstodo- # From global config
nameSuffix: -prod # Environment specific

helmCharts:
  - name: app # Generic name
    releaseName: app # Kustomize handles prefixes/suffixes
```

### Resulting Names

- **Final Resource Names**: `vanillatstodo-app-prod`
- **Helm Release Name**: `vanillatstodo-app-prod`
- **ConfigMaps**: `vanillatstodo-global-config-prod`

## Benefits of This Approach

### 1. **Reusability**

```bash
# Easy to clone for new projects
cp -r devops/config devops-newproject/config
sed -i 's/vanillatstodo/newproject/g' devops-newproject/config/global.env
```

### 2. **Consistency**

- All environments follow the same naming convention
- Predictable resource names across environments
- Unified labeling strategy

### 3. **Maintainability**

- Single source of truth for project configuration
- Change project name in one place
- No scattered hardcoded values

### 4. **GitOps Integration**

```yaml
# ArgoCD Application - No hardcoded names!
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: app-production # Environment-specific only
spec:
  source:
    path: devops/kustomize-app/overlays/production
  # namePrefix/nameSuffix handled by Kustomize
```

## Environment Variable Usage

### Available in All Deployments

Variables from `global.env` are available as a ConfigMap in all environments:

```bash
# View available variables
kubectl get configmap global-config -o yaml

# Use in Pod specifications
envFrom:
- configMapRef:
    name: global-config
```

### Environment-Specific Overrides

Each overlay can override global values:

```yaml
# devops/kustomize-app/overlays/production/kustomization.yaml
configMapGenerator:
  - name: environment-config
    literals:
      - ENVIRONMENT=production
      - LOG_LEVEL=warn
      - MONITORING_ENABLED=true
```

## Best Practices

### 1. **Configuration Structure**

```bash
devops/config/
├── global.env              # Project-wide constants
├── app.env                 # Application-specific config
├── monitoring.env          # Monitoring-specific config
└── infrastructure.env      # Infrastructure config
```

### 2. **Naming Conventions**

- **Base names**: Generic (`app`, `monitoring`, `database`)
- **Prefixes**: Project name (`vanillatstodo-`)
- **Suffixes**: Environment (`-prod`, `-staging`, `-exp`)
- **Final result**: `vanillatstodo-app-prod`

### 3. **Environment Separation**

```yaml
# Different namespaces per environment
namespace: vanillatstodo-prod      # Production
namespace: vanillatstodo-staging   # Staging
namespace: vanillatstodo-exp       # Experimental
```

### 4. **Version Management**

```bash
# Track configuration changes
git tag config-v1.0.0
git commit -m "feat: update global config for v1.0.0"
```

## Migration Guide

### From Hardcoded to Dynamic

1. **Create global config**:

```bash
mkdir -p devops/config
cat > devops/config/global.env << 'EOF'
PROJECT_NAME=your-project-name
APP_VERSION=1.0.0
EOF
```

2. **Update base configurations**:

```yaml
configMapGenerator:
  - name: global-config
    envs:
      - ../../config/global.env
```

3. **Update overlays**:

```yaml
namePrefix: your-project-name-
nameSuffix: -env
```

4. **Remove hardcoded names**:

```bash
# Find all hardcoded references
grep -r "vanillatstodo-" devops/kustomize-*/

# Replace with dynamic alternatives
# metadata.name: monitoring-production (not vanillatstodo-monitoring-production)
# helmCharts.name: app (not vanillatstodo-app)
```

## Troubleshooting

### Common Issues

1. **ConfigMap not found**:

```bash
# Ensure global.env exists and is referenced correctly
ls -la devops/config/global.env
```

2. **Name collisions**:

```bash
# Check generated names
kubectl kustomize devops/kustomize-app/overlays/production | grep "name:"
```

3. **Environment variables not available**:

```bash
# Verify ConfigMap generation
kubectl get configmap global-config -o yaml
```

### Validation Commands

```bash
# Test all overlays
for env in experimental staging production; do
  echo "Testing $env..."
  kubectl kustomize devops/kustomize-app/overlays/$env --dry-run=client
done

# Check generated resource names
kubectl kustomize devops/kustomize-app/overlays/production | grep -E "^  name:"

# Verify environment separation
kubectl kustomize devops/kustomize-app/overlays/production | grep "namespace:"
```

This centralized configuration approach is the **industry standard** for Kubernetes deployments and follows GitOps best practices! 🎯
