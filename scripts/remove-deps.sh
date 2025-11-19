# Remove cert-manager
oc delete deployment -n cert-manager -l app.kubernetes.io/instance=cert-manager
oc patch certmanagers.operator cluster --type=merge -p='{"metadata":{"finalizers":null}}'
oc delete crd -l app.kubernetes.io/instance=cert-manager
oc delete crd certmanagers.operator.openshift.io
