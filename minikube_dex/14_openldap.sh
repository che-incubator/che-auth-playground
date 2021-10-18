#!/bin/bash

kubectl create namespace openldap

# Creates a secret containing the admin user password
kubectl create secret generic openldap --from-literal=adminpassword=adminpassword -n openldap

# Installs OpenLDAP
kubectl apply -f openldap.yaml -n openldap

until [ $( kubectl get pods -n openldap | grep Running | wc -l) -eq 1 ]; do echo "Waiting for OpenLDAP ..."; sleep 3; done
