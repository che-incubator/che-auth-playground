#!/bin/bash

helm repo add skm https://charts.sagikazarmark.dev

helm repo update

NAMESPACE=dex

K8S_CA_PEM=$(kubectl config view --minify --flatten -o json | jq -r '.clusters[] | select(.name == "'$(kubectl config current-context)'") | .cluster."certificate-authority-data"'|base64 -D | sed 's/^/        /')

MINIKUBE_IP=$(minikube ip)

TRUSTED_ROOT_CA=$(cat ssl/ca.pem | sed 's/^/        /')

TRUSTED_ROOT_CA=$TRUSTED_ROOT_CA MINIKUBE_IP=$MINIKUBE_IP K8S_CA_PEM=$K8S_CA_PEM envsubst < dex-k8s-authenticator-override-values.yaml > values.yaml

helm upgrade --install dex-k8s-authenticator skm/dex-k8s-authenticator --namespace $NAMESPACE --version 0.0.1 --values values.yaml

until [ $( kubectl get ingress -n "${NAMESPACE}" | grep dex-k8s-authenticator | grep -o $( minikube ip ) | wc -l) -eq 2 ]; do echo "Waiting for ingress ..."; sleep 3; done

rm -rf values.yaml
