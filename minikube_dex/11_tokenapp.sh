#!/bin/bash

kubectl create secret -n che \
    generic root-ca \
    --from-file=ca.pem=ssl/ca.pem

sed "s/{{MINIKUBE_IP}}/$( minikube ip )/g" tokenapp.yaml | kubectl apply -n che -f -

until [ $( kubectl get ingress -n che | grep oidc-example-app | grep -o $( minikube ip ) | wc -l) -eq 2 ]; do echo "Waiting for ingress ..."; sleep 3; done

echo
echo "http://oidc-example-app.$( minikube ip ).nip.io"
echo "email login credentials => che@eclipse.org:password"
echo
