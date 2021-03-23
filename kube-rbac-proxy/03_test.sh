#!/bin/bash

NAMESPACE=${1:-che}
TOKEN=${2}

if [ -z ${TOKEN} ]; then
  echo
  echo "You can pass the token to the script like './03_test.sh <namespace> <token>'"
  echo "If you've deployed with minikube+dex setup, you can get the token after login at http://oidc-example-app.$( minikube ip ).nip.io/"
  echo
  echo
  echo
fi

MINIKUBE_IP=$( minikube ip )
set -x

curl -X GET -H "Authorization: Bearer ${TOKEN}" "http://${NAMESPACE}-kube-rbac-app.${MINIKUBE_IP}.nip.io/query?namespace=${NAMESPACE}"
