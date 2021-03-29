#!/bin/bash

NAMESPACE=${1}
USER=${2:-${NAMESPACE}@che}

if [ -z ${NAMESPACE} ]; then
  echo "you have to define the namespace './01_deploy <namespace>'"
  exit 1
fi

echo "Preparing namespace '${NAMESPACE}' for user '${USER}'"

kubectl create namespace ${NAMESPACE}

echo "
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ${NAMESPACE}-admin
subjects:
  - kind: User
    name: ${USER}
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: admin
  apiGroup: rbac.authorization.k8s.io
" | kubectl apply -n ${NAMESPACE} -f -

# deploy app with kube-rbac-proxy
sed "s/{{NAMESPACE}}/${NAMESPACE}/g" deploy.yaml | kubectl apply -n ${NAMESPACE} -f -
sed "s/{{NAMESPACE}}/${NAMESPACE}/g" route-config.yaml | kubectl apply -n che -f -

# until [ $( kubectl get ingress -n ${NAMESPACE} | grep "${NAMESPACE}-app" | grep -o $( minikube ip ) | wc -l) -eq 2 ]; do echo "Waiting for ingress ..."; sleep 3; done
echo
echo "https://che.$( minikube ip ).nip.io/${NAMESPACE}"
echo
