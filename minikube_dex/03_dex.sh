#!/bin/bash

MINIKUBE_DOMAIN=$( minikube ip ).nip.io

kubectl create namespace dex

# prepare namespace with cert and github oauth secrets
kubectl create secret tls dex.tls --cert=ssl/cert.pem --key=ssl/key.pem -n dex
kubectl create secret -n dex \
    generic github-client \
    --from-literal=client-id="${GITHUB_CLIENT_ID}" \
    --from-literal=client-secret="${GITHUB_CLIENT_SECRET}"

# deploy dex
sed "s/{{MINIKUBE_IP}}/$( minikube ip )/g" dex.yaml | kubectl apply -n dex -f -

until [ $( kubectl get pods -n dex | grep Running | wc -l) -eq 1 ]; do echo "Waiting for DEX ..."; sleep 3; done
