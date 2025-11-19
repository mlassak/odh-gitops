# Default target
help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

##@ Tools

## Location to install dependencies to
LOCALBIN ?= $(shell pwd)/bin
$(LOCALBIN):
	mkdir -p $(LOCALBIN)
CLEANFILES += $(LOCALBIN)

## Tool Binaries
KUSTOMIZE ?= $(LOCALBIN)/kustomize

## Tool Versions
KUSTOMIZE_VERSION ?= v5.8.0

KUSTOMIZE_INSTALL_SCRIPT ?= "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"
.PHONY: kustomize
kustomize: $(KUSTOMIZE) ## Download kustomize locally if necessary.
$(KUSTOMIZE): $(LOCALBIN)
	$(call go-install-tool,$(KUSTOMIZE),sigs.k8s.io/kustomize/kustomize/v5,$(KUSTOMIZE_VERSION))

# Validate kustomize targets
.PHONY: validate
validate: kustomize ## Build all kustomize directories in the project
	@echo "Building all kustomizations..."
	$(call kustomize-build-folder,dependencies)
	$(call kustomize-build-folder,components)
	@echo ""
	@echo "All kustomizations built successfully! ✓"

.PHONY: apply
apply: kustomize ## Apply kustomize directory as passed as argument
	@echo "Applying kustomization $(FOLDER)..."
	@if [ -z "$(FOLDER)" ]; then \
		echo "Error: FOLDER variable is required. Usage: make apply FOLDER=<path>"; \
		exit 1; \
	fi
	$(KUSTOMIZE) build $(FOLDER) | kubectl apply $(KUBECTL_FLAGS) -f -
	@echo ""
	@echo "Kustomization $(FOLDER) applied successfully! ✓"

.PHONY: remove
remove: kustomize ## Remove kustomize directory as passed as argument
	@echo "Applying kustomization $(FOLDER)..."
	@if [ -z "$(FOLDER)" ]; then \
		echo "Error: FOLDER variable is required. Usage: make apply FOLDER=<path>"; \
		exit 1; \
	fi
	$(KUSTOMIZE) build $(FOLDER) | kubectl delete $(KUBECTL_FLAGS) -f -

.PHONY: remove-all-dependencies
remove-all-dependencies:
	@echo "Removing all dependencies..."
	# @$(MAKE) remove FOLDER=dependencies
	@bash ./scripts/remove-deps.sh
	@echo "All dependencies removed successfully! ✓"

.PHONY: dry-run
dry-run: kustomize ## Dry run kustomize directory as passed as argument
	@$(MAKE) apply FOLDER=$(FOLDER) KUBECTL_FLAGS="--dry-run=client -o yaml"

.PHONY: clean
clean:
	rm -rf $(CLEANFILES)

# go-install-tool will 'go install' any package with custom target and name of binary, if it doesn't exist
# $1 - target path with name of binary (ideally with version)
# $2 - package url which can be installed
# $3 - specific version of package
define go-install-tool
@[ -f "$(1)-$(3)" ] || { \
set -e; \
package=$(2)@$(3) ;\
echo "Downloading $${package}" ;\
rm -f $(1) || true ;\
GOBIN=$(LOCALBIN) go install $${package} ;\
mv $(1) $(1)-$(3) ;\
} ;\
ln -sf $(1)-$(3) $(1)
endef

# kustomize-build-folder will run kustomize build on all kustomization files in a folder
# $1 - folder path to search
# $2 - additional kustomize build flags (optional)
define kustomize-build-folder
@if [ -z "$(1)" ]; then \
	echo "Error: folder path is required"; \
	exit 1; \
fi
@for dir in $$(find $(1) -name "kustomization.yaml" -o -name "kustomization.yml" | xargs -n1 dirname | sort -u); do \
	$(KUSTOMIZE) build $$dir > /dev/null && echo "  ✓ $$dir" || (echo "  ✗ $$dir FAILED" && exit 1); \
done
endef
