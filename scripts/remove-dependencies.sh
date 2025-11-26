# Remove cert-manager
oc delete --ignore-not-found deployment -n cert-manager -l app.kubernetes.io/instance=cert-manager
oc patch certmanagers.operator cluster --type=merge -p='{"metadata":{"finalizers":null}}'
oc delete --ignore-not-found crd -l app.kubernetes.io/instance=cert-manager
oc delete --ignore-not-found crd certmanagers.operator.openshift.io
oc delete --ignore-not-found namespace cert-manager
