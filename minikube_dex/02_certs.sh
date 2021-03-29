#!/bin/bash

set -x

MINIKUBE_DOMAIN=$( minikube ip ).nip.io

rm -rf ssl && mkdir -p ssl


## generate certs
DOMAIN="dex.${MINIKUBE_DOMAIN}"
echo $DOMAIN
DNS_ENTRIES=DNS:${DOMAIN},DNS:*.${DOMAIN},DNS:*.sharded.${DOMAIN},DNS:che.${MINIKUBE_DOMAIN}
CHE_CA_CN='Local Dex Signer'
CHE_CA_KEY_FILE='ssl/ca.key'
CHE_CA_CERT_FILE='ssl/ca.pem'
CHE_SERVER_ORG='Local Dex'
CHE_SERVER_KEY_FILE='ssl/key.pem'
CHE_SERVER_CERT_REQUEST_FILE='ssl/domain.csr'
CHE_SERVER_CERT_FILE='ssl/cert.pem'

# Figure out openssl configuration file location
OPENSSL_CNF='/etc/pki/tls/openssl.cnf'
if [ ! -f $OPENSSL_CNF ]; then
    OPENSSL_CNF='/etc/ssl/openssl.cnf'
fi
openssl genrsa -out $CHE_CA_KEY_FILE 4096
openssl req -new -x509 -nodes -key $CHE_CA_KEY_FILE -sha256 \
            -subj /CN="${CHE_CA_CN}" \
            -days 1024 \
            -reqexts SAN -extensions SAN \
            -config <(cat ${OPENSSL_CNF} <(printf '[SAN]\nbasicConstraints=critical, CA:TRUE\nkeyUsage=keyCertSign, cRLSign, digitalSignature')) \
            -outform PEM -out $CHE_CA_CERT_FILE
openssl genrsa -out $CHE_SERVER_KEY_FILE 2048
openssl req -new -sha256 -key $CHE_SERVER_KEY_FILE \
            -subj "/O=${CHE_SERVER_ORG}/CN=${MINIKUBE_DOMAIN}" \
            -reqexts SAN \
            -config <(cat $OPENSSL_CNF <(printf "\n[SAN]\nsubjectAltName=${DNS_ENTRIES}\nbasicConstraints=critical, CA:FALSE\nkeyUsage=digitalSignature, keyEncipherment, keyAgreement, dataEncipherment\nextendedKeyUsage=serverAuth")) \
            -outform PEM -out $CHE_SERVER_CERT_REQUEST_FILE
openssl x509 -req -in $CHE_SERVER_CERT_REQUEST_FILE -CA $CHE_CA_CERT_FILE -CAkey $CHE_CA_KEY_FILE -CAcreateserial \
             -days 365 \
             -sha256 \
             -extfile <(printf "subjectAltName=${DNS_ENTRIES}\nbasicConstraints=critical, CA:FALSE\nkeyUsage=digitalSignature, keyEncipherment, keyAgreement, dataEncipherment\nextendedKeyUsage=serverAuth") \
             -outform PEM -out $CHE_SERVER_CERT_FILE
cat $CHE_SERVER_CERT_FILE $CHE_CA_CERT_FILE > ssl/kube.crt


## copy certs so minikube can see it
mkdir -p ~/.minikube/files/etc/ca-certificates/
cp ssl/ca.pem ~/.minikube/files/etc/ca-certificates/openid-ca.pem

kubectl create secret -n che generic root-ca --from-file=ca.pem=ssl/ca.pem

set +x

echo
echo "Action item ===> Import 'ssl/ca.pem' into your browser <==="
echo