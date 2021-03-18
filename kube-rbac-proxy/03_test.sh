#!/bin/bash

TOKEN=${1}

if [ -z ${TOKEN} ]; then
  echo
  echo "You can pass the token to the script like './03_test.sh <token>'"
  echo "If you've deployed with minikube+dex setup, you can get the token after login at http://oidc-example-app.$( minikube ip ).nip.io/"
  echo
  echo
  echo
fi

MINIKUBE_IP=$( minikube ip )
set -x

curl -H "Authorization: Bearer ${TOKEN}" "http://kube-rbac-app.${MINIKUBE_IP}.nip.io/query"
