echo "Verifying dependencies..."

# wait_for_resource - Wait for Kubernetes resources to exist (retries every 5s)
# Usage: wait_for_resource <namespace> <resource_type> <label> [timeout_seconds]
# Returns: 0 on success, 1 on timeout
# Example: wait_for_resource "default" "pods" "app=myapp" 300
wait_for_resource() {
    local namespace=$1
    local resource_type=$2
    local label=$3
    local description="resource ${resource_type} in namespace ${namespace} with label ${label}"
    local timeout=${5:-300}
    local interval=5
    local elapsed=0

    echo "Waiting for ${description}..."
    while ! oc get ${resource_type} -n ${namespace} -l ${label} 2>/dev/null | grep -q .; do
        if [ $elapsed -ge $timeout ]; then
            echo "ERROR: ${description} not found after ${timeout}s"
            return 1
        fi
        sleep $interval
        elapsed=$((elapsed + interval))
    done
    echo "✓ ${description} found"
    return 0
}

# wait_for_csv_succeeded - Wait for CSV (ClusterServiceVersion) to reach Succeeded phase
# Usage: wait_for_csv_succeeded <namespace> <csv_name> [timeout_seconds]
# Returns: 0 on success, 1 on timeout or failure
# Example: wait_for_csv_succeeded "cert-manager" "cert-manager.v1.15.0" 300
wait_for_csv_succeeded() {
    local namespace=$1
    local csv_name=$2
    local timeout=${3:-300}
    local interval=5
    local elapsed=0

    echo "Waiting for CSV ${csv_name} in namespace ${namespace} to reach Succeeded phase..."

    while true; do
        # Check if CSV exists and get its phase
        local phase=$(oc get csv ${csv_name} -n ${namespace} -o jsonpath='{.status.phase}' 2>/dev/null)

        if [ "$phase" = "Succeeded" ]; then
            echo "✓ CSV ${csv_name} has reached Succeeded phase"
            return 0
        fi

        if [ $elapsed -ge $timeout ]; then
            echo "ERROR: CSV ${csv_name} did not reach Succeeded phase after ${timeout}s (current phase: ${phase:-not found})"
            return 1
        fi

        if [ -n "$phase" ] && [ "$phase" != "Succeeded" ]; then
            echo "  Current phase: ${phase} (waiting...)"
        fi

        sleep $interval
        elapsed=$((elapsed + interval))
    done
}

# wait_for_subscription_csv - Wait for CSV from a Subscription to reach Succeeded phase
# Usage: wait_for_subscription_csv <namespace> <subscription_name> [timeout_seconds]
# Returns: 0 on success, 1 on timeout or failure
# Example: wait_for_subscription_csv "cert-manager" "cert-manager" 300
wait_for_subscription_csv() {
    local namespace=$1
    local subscription_name=$2
    local timeout=${3:-300}
    local interval=5
    local elapsed=0

    echo "Waiting for Subscription ${subscription_name} in namespace ${namespace} to have a CSV..."

    # First, wait for the subscription to have a currentCSV
    while true; do
        local csv_name=$(oc get subscription ${subscription_name} -n ${namespace} -o jsonpath='{.status.currentCSV}' 2>/dev/null)

        if [ -n "$csv_name" ]; then
            echo "✓ Found CSV: ${csv_name}"
            break
        fi

        if [ $elapsed -ge $timeout ]; then
            echo "ERROR: Subscription ${subscription_name} did not get a CSV after ${timeout}s"
            return 1
        fi

        sleep $interval
        elapsed=$((elapsed + interval))
    done

    # Now wait for the CSV to reach Succeeded phase
    wait_for_csv_succeeded "${namespace}" "${csv_name}" "${timeout}"
    return $?
}

# cert-manager
echo "Waiting for cert-manager to be ready..."
if ! wait_for_subscription_csv "cert-manager-operator" "openshift-cert-manager-operator"; then
    exit 1
fi
if ! wait_for_resource "cert-manager" "pods" "app.kubernetes.io/instance=cert-manager"; then
    exit 1
fi
echo "✓ cert-manager is installed and ready"

# kueue
echo "Waiting for kueue to be ready..."
if ! wait_for_subscription_csv "openshift-kueue-operator" "kueue-operator"; then
    exit 1
fi
echo "✓ kueue is installed and ready"

# cluster-observability-operator
echo "Waiting for cluster-observability-operator to be ready..."
if ! wait_for_subscription_csv "openshift-cluster-observability-operator" "cluster-observability-operator"; then
    exit 1
fi
echo "✓ cluster-observability-operator is installed and ready"
