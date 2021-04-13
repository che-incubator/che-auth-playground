#!/bin/bash

NAMESPACE=che

kubectl create secret tls che-tls --key=../minikube_dex/ssl/key.pem --cert=../minikube_dex/ssl/cert.pem -n ${NAMESPACE} || true

cat rbac.yaml | kubectl apply -n ${NAMESPACE} -f -
sed "s/{{MINIKUBE_IP}}/$( minikube ip )/g" o2p_config.yaml | kubectl apply -n ${NAMESPACE} -f -
cat traefik_config.yaml | kubectl apply -n ${NAMESPACE} -f -
sed "s/{{MINIKUBE_IP}}/$( minikube ip )/g" deploy.yaml | kubectl apply -n ${NAMESPACE} -f -

until [ $( kubectl get ingress -n ${NAMESPACE} | grep gateway | grep -o $( minikube ip ) | wc -l) -eq 2 ]; do echo "Waiting for ingress ..."; sleep 3; done
echo
echo "http://che.$( minikube ip ).nip.io"
echo
