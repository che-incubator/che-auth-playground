#!/bin/bash

MINIKUBE_DOMAIN=$( minikube ip ).nip.io

# prepare namespace with cert and github oauth secrets
kubectl create secret tls dex.tls --cert=ssl/cert.pem --key=ssl/key.pem -n dex
kubectl create secret -n dex \
    generic github-client \
    --from-literal=client-id="${GITHUB_CLIENT_ID}" \
    --from-literal=client-secret="${GITHUB_CLIENT_SECRET}"

# deploy dex
sed "s/{{MINIKUBE_IP}}/$( minikube ip )/g" dex.yaml | oc apply -n dex -f -
