#!/bin/bash

NAMESPACE=${1}
USER=${2:-${NAMESPACE}@che}

if [ -z ${NAMESPACE} ]; then
  echo "you have to define the namespace './01_deploy <namespace>'"
  exit 1
fi

# deploy app with kube-rbac-proxy
sed "s/{{MINIKUBE_IP}}/$( minikube ip )/g; s/{{NAMESPACE}}/${NAMESPACE}/g" deploy.yaml | kubectl apply -n ${NAMESPACE} -f -

until [ $( kubectl get ingress -n ${NAMESPACE} | grep kube-rbac-app | grep -o $( minikube ip ) | wc -l) -eq 2 ]; do echo "Waiting for ingress ..."; sleep 3; done
echo
echo "http://${NAMESPACE}-kube-rbac-app.$( minikube ip ).nip.io"
echo
