#!/bin/bash

NAMESPACE=che
CLUSTER_HOSTNAME=${CLUSTER_HOSTNAME:-apps-crc.testing}

kubectl create namespace ${NAMESPACE}

cat rbac.yaml | kubectl apply -n ${NAMESPACE} -f -
sed "s/{{HOSTNAME}}/${CLUSTER_HOSTNAME}/g" oauth.yaml | kubectl apply -n ${NAMESPACE} -f -
sed "s/{{HOSTNAME}}/${CLUSTER_HOSTNAME}/g" o2p_config.yaml | kubectl apply -n ${NAMESPACE} -f -
cat traefik_config.yaml | kubectl apply -n ${NAMESPACE} -f -
sed "s/{{HOSTNAME}}/${CLUSTER_HOSTNAME}/g" deploy.yaml | kubectl apply -n ${NAMESPACE} -f -
cat testapp.yaml | kubectl apply -n ${NAMESPACE} -f -

echo
echo "https://che.${CLUSTER_HOSTNAME}"
echo
