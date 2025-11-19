# Contributing to OpenShift AI GitOps Repository

Thank you for your interest in contributing to the OpenShift AI GitOps repository! This document provides guidelines and instructions for contributing to this project.

## Table of Contents

- [Contributing to OpenShift AI GitOps Repository](#contributing-to-openshift-ai-gitops-repository)
  - [Table of Contents](#table-of-contents)
  - [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
  - [Add a New Dependency Operator](#add-a-new-dependency-operator)
    - [Step 1: Create a new operator component](#step-1-create-a-new-operator-component)
    - [Step 2: Create Required Manifests](#step-2-create-required-manifests)
    - [Step 3: Create Dependency Operator Directory](#step-3-create-dependency-operator-directory)
    - [Step 4: Update Operators Parent Kustomization](#step-4-update-operators-parent-kustomization)
    - [Step 5: Document the Operator](#step-5-document-the-operator)
    - [Step 6: Test Your Changes](#step-6-test-your-changes)
  - [Testing Your Changes](#testing-your-changes)
    - [Local Validation](#local-validation)
  - [Pull Requests](#pull-requests)
    - [Workflow](#workflow)
    - [Open a Pull Request](#open-a-pull-request)
    - [Commit Messages](#commit-messages)

## Getting Started

### Prerequisites

- Git
- `kubectl` or `oc` CLI
- Access to an OpenShift cluster (for testing)
- Kustomize v5 or later

## Add a New Dependency Operator

When adding a new dependency operator required by OpenShift AI:

### Step 1: Create a new operator component

Create a new directory under `components/operators/` named after your operator:

```bash
mkdir -p components/operators/your-operator
```

### Step 2: Create Required Manifests

Create the files required to install the dependency operator in your operator directory, with the `kustomization.yaml` file in the same directory.

> [!NOTE]
> Do not set namespace name in the kustomization.yaml file, but set it as string where needed.

### Step 3: Create Dependency Operator Directory

Create a new directory under `dependencies/operators/` named after your operator:

```bash
mkdir -p dependencies/operators/your-operator
```

add a `kustomization.yaml` file to the directory, e.g.:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - your-operator/
```

and the patches if needed.

If the dependency operator depends on other operators, add them to the `components` list.
An example can be found in the [kueue operator](dependencies/operators/kueue-operator/kustomization.yaml) directory.

### Step 4: Update Operators Parent Kustomization

Add your operator to `dependencies/operators/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - cert-manager/
  - kueue-operator/
  - your-operator/  # Add this line
```

### Step 5: Document the Operator

Add documentation about your operator:

1. Update `README.md` with operator information
2. Add any special configuration requirements

### Step 6: Test Your Changes

See [Testing Your Changes](#testing-your-changes) section below.

## Testing Your Changes

Always test your changes before submitting a PR.

### Local Validation

1. **Validate Kustomize Build**:

   ```bash
   # Test building your specific operator/component
   kustomize build dependencies/operators/your-operator

   # Test building all dependencies
   kustomize build dependencies
   ```

2. **Check for YAML Errors**:

   ```bash
   kustomize build . | kubectl apply --dry-run=client -f -
   ```

3. **Validate installation on a real cluster**

## Pull Requests

### Workflow

1. **Fork the Repository:** Create your own fork of the repository to work on your changes.
2. **Create a Branch:** Create your own branch to include changes for the feature or a bug fix off of `main` branch.
3. **Work on Your Changes:** Commit often, and ensure kustomize build correctly.
4. **Testing:** Make sure to test you changes in a real cluster. See [Testing Your Changes](#testing-your-changes) section above.
5. **Open a PR Against `main`:** See PR guidelines below.

### Open a Pull Request

1. **Link to Jira Issue**: Include the Jira issue link in your PR description.
2. **Description**: Provide a detailed description of the changes and what they fix or implement.
3. **Add Testing Steps**: Provide information on how the PR has been tested, and list out testing steps if any for reviewers.
4. **Review Request**: Tag the relevant maintainers or team members for a review. We follow the [kubernetes review process](https://github.com/kubernetes/community/blob/master/contributors/guide/owners.md#the-code-review-process).
5. **Resolve Feedback**: Be open to feedback and iterate on your changes.
6. 
### Commit Messages

We follow the conventional commits format for writing commit messages. A good commit message should include:

1. **Type:** `fix`, `feat`, `docs`, `chore`, etc. **Note:** All commits except `chore` require an associated jira issue. Please add link to your jira issue.
2. **Scope:** A short description of the area affected.
3. **Summary:** A brief explanation of what the commit does.
