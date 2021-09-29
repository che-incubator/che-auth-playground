#!/bin/bash

set -x

MINIKUBE_DOMAIN=$( minikube ip ).nip.io



minikube \
  --extra-config="apiserver.oidc-issuer-url=https://dex.${MINIKUBE_DOMAIN}:32000" \
  --extra-config="apiserver.oidc-client-id=example-app" \
  --extra-config="apiserver.oidc-ca-file=/etc/ca-certificates/openid-ca.pem" \
  --extra-config="apiserver.oidc-username-claim=email" \
  --extra-config="apiserver.oidc-groups-claim=groups" \
  start

set +x
sleep 5
until kubectl get pods -n kube-system | grep apiserver | grep 1/1; do echo "Kubernetes apiserver restarting. Waiting..."; sleep 5; done
