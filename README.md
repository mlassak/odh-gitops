# Red Hat OpenShift AI - GitOps Repository

This repository provides a GitOps-based approach to deploying and managing Red Hat OpenShift AI and its dependencies using Kustomize. It serves as a standardized, repeatable, and automated way to set up the complete OpenShift AI stack.

## Table of Contents

- [Red Hat OpenShift AI - GitOps Repository](#red-hat-openshift-ai---gitops-repository)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
    - [How the Structure Works](#how-the-structure-works)
    - [Dependencies](#dependencies)
  - [Quick Start](#quick-start)
    - [Prerequisites](#prerequisites)
    - [Basic Installation](#basic-installation)
  - [Installation Methods](#installation-methods)
    - [Install All Dependencies](#install-all-dependencies)
    - [Install Specific Dependency](#install-specific-dependency)
    - [Install a subset of dependencies](#install-a-subset-of-dependencies)
  - [Usage Guidelines](#usage-guidelines)
    - [For Administrators](#for-administrators)
  - [Release Strategy](#release-strategy)

## Overview

This repository addresses the OpenShift AI dependencies that are treated as **administrator-owned resources** that we help bootstrap.

This repository provides a template for a standardized way to deploy these prerequisites, simplifying the administrator's workflow by providing a single source of truth for the entire OpenShift AI stack.

This repository can work for both GitOps tools (ArgoCD, Flux, etc.) and `oc` or `kubectl` CLI.

### How the Structure Works

The repository is designed to be applied in **layers**, providing flexibility in deployment:

1. **Granular Installation**: Each dependency or component has its own `kustomization.yaml` and can be applied independently
2. **Grouped Installation**: Top-level folders contain `kustomization.yaml` files that include all items within them
3. **Full Installation**: The `rhoai/kustomization.yaml` installs the entire OpenShift AI stack with a single command
4. **Composition**: Each component is self-contained and includes its required dependencies

### Dependencies

| Operator | Purpose | Namespace | Required By |
|----------|---------|-----------|-------------|
| **Cert-Manager** | Automated certificate management and TLS provisioning | `cert-manager-operator` | Model Serving (Kueue, Ray) |

## Quick Start

### Prerequisites

- OpenShift cluster (version 4.19 or later)
- `kubectl` or `oc` CLI installed
- Cluster admin permissions
- Kustomize v5 or later (or use `kubectl apply -k`)

### Basic Installation

```bash
# 1. Clone the repository
git clone https://github.com/davidebianchi/rhoai-gitops.git
cd rhoai-gitops

# 2. Checkout the branch matching your OpenShift AI version
git checkout rhoai-3.0

# 3. Install all dependencies
kubectl apply -k dependencies

# 4. Wait for operators to be ready
```

## Installation Methods

### Install All Dependencies

```bash
# Install all dependencies
kubectl apply -k dependencies
```

### Install Specific Dependency

```bash
kubectl apply -k dependencies/operators/cert-manager
kubectl apply -k dependencies/operators/kueue-operator
```

### Install a subset of dependencies

It is possible to modify the dependencies/operators/kustomization.yaml to comment out the dependencies you don't need.
For example, if the Kueue operator is not needed, it can be commented out like this:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

components:
  - ../../components/operators/cert-manager
  # - ../../components/operators/kueue-operator
```

If the Kueue operator is needed later, it can be uncommented and the changes applied.

## Usage Guidelines

### For Administrators

1. **Fork or Clone** this repository as a starting point for your organization
2. **Select the Branch** matching your target OpenShift AI version (e.g., `rhoai-3.0`)
3. **Customize** the configurations for your specific environment
4. **Test** thoroughly in a non-production environment
5. **Maintain** your fork with updates and customizations
6. **Apply** using your GitOps tool (ArgoCD, Flux, etc.) or `kubectl`

## Release Strategy

- **No Formal Releases**: This repository does not have official releases. Users are expected to clone or fork the repository and use it as a basis for their own configurations.
- **Branch per OpenShift AI Version**: Each version of OpenShift AI has a dedicated branch (e.g., `rhoai-3.0`, `rhoai-3.1`) to ensure compatibility
- **Version Selection**: Always select the branch corresponding to your target OpenShift AI version
