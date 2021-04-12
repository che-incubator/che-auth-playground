#!/bin/bash

NAMESPACE=che
HOSTNAME=apps.cluster-253a.253a.sandbox483.opentlc.com

kubectl create namespace ${NAMESPACE}

# kubectl create secret tls che-tls --key=../minikube_dex/ssl/key.pem --cert=../minikube_dex/ssl/cert.pem -n ${NAMESPACE} || true

cat rbac.yaml | kubectl apply -n ${NAMESPACE} -f -
sed "s/{{HOSTNAME}}/${HOSTNAME}/g" oauth.yaml | kubectl apply -n ${NAMESPACE} -f -
sed "s/{{HOSTNAME}}/${HOSTNAME}/g" o2p_config.yaml | kubectl apply -n ${NAMESPACE} -f -
cat traefik_config.yaml | kubectl apply -n ${NAMESPACE} -f -
sed "s/{{HOSTNAME}}/${HOSTNAME}/g" deploy.yaml | kubectl apply -n ${NAMESPACE} -f -
cat testapp.yaml | kubectl apply -n ${NAMESPACE} -f -

# until [ $( kubectl get ingress -n ${NAMESPACE} | grep gateway | grep -o $( minikube ip ) | wc -l) -eq 2 ]; do echo "Waiting for ingress ..."; sleep 3; done
# echo
# echo "http://che.$( minikube ip ).nip.io"
# echo
