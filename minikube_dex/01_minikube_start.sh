#!/bin/bash

set -x

minikube --memory 6gb --disk-size 40g --driver='kvm2' start

minikube addons enable ingress

kubectl create namespace dex
kubectl create namespace che
