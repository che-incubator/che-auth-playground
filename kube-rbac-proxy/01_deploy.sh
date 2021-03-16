#!/bin/bash

# deploy dex
sed "s/{{MINIKUBE_IP}}/$( minikube ip )/g" deploy.yaml | kubectl apply -n che -f -

until [ $( kc get ingress -n che | grep kube-rbac-app | grep -o $( minikube ip ) | wc -l) -eq 2 ]; do echo "Waiting for ingress ..."; sleep 3; done
echo
echo "http://kube-rbac-app.$( minikube ip ).nip.io"
echo