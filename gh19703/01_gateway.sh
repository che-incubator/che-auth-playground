#!/bin/bash

NAMESPACE=eclipse-che
CLUSTER_HOSTNAME=$( kubectl get route che -n ${NAMESPACE} -o json | jq -r '.spec.host' )

kubectl delete deployment che-gateway -n ${NAMESPACE}
kubectl delete service che-gateway -n ${NAMESPACE}
kubectl delete route che -n ${NAMESPACE}

cat rbac.yaml | kubectl apply -n ${NAMESPACE} -f -
sed "s/{{HOSTNAME}}/${CLUSTER_HOSTNAME}/g" oauth.yaml | kubectl apply -n ${NAMESPACE} -f -
sed "s/{{HOSTNAME}}/${CLUSTER_HOSTNAME}/g" o2p_config.yaml | kubectl apply -n ${NAMESPACE} -f -
cat traefik_config.yaml | kubectl apply -n ${NAMESPACE} -f -
sed "s/{{HOSTNAME}}/${CLUSTER_HOSTNAME}/g" deploy.yaml | kubectl apply -n ${NAMESPACE} -f -

echo
echo "https://${CLUSTER_HOSTNAME}"
echo
