#!/bin/bash

sed "s/{{MINIKUBE_IP}}/$( minikube ip )/g" tokenapp.yaml | kubectl apply -n che -f -

until [ $( kubectl get ingress -n che | grep oidc-example-app | grep -o $( minikube ip ) | wc -l) -eq 2 ]; do echo "Waiting for ingress ..."; sleep 3; done

echo
echo "http://oidc-example-app.$( minikube ip ).nip.io"
echo "email login credentials:"
echo "   che@eclipse.org:password"
echo "   user1@che:password"
echo "   user2@che:password"
echo "   user3@che:password"
echo "   user4@che:password"
echo "   user5@che:password"
echo
