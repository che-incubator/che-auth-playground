#!/bin/bash

helm repo add skm https://charts.sagikazarmark.dev

helm repo update

NAMESPACE=dex

sed "s/{{MINIKUBE_IP}}/$( minikube ip )/g" dex-k8s-authenticator-override-values.yaml > values.yaml

helm upgrade --install dex-k8s-authenticator skm/dex-k8s-authenticator --namespace $NAMESPACE --version 0.0.1 --values values.yaml

until [ $( kubectl get ingress -n "${NAMESPACE}" | grep dex-k8s-authenticator | grep -o $( minikube ip ) | wc -l) -eq 2 ]; do echo "Waiting for ingress ..."; sleep 3; done

rm -rf values.yaml