#!/bin/bash

sed "s/{{MINIKUBE_IP}}/$( minikube ip )/g" testapp.yaml | oc apply -n che -f -

until [ $( kc get ingress -n che | grep che-auth-testapp | grep -o $( minikube ip ) | wc -l) -eq 2 ]; do echo "Waiting for ingress ..."; sleep 3; done

echo
echo "http://che-auth-testapp.$( minikube ip ).nip.io"
echo
