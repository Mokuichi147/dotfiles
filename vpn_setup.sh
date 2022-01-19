#!/bin/sh

if [ $# -ne 2 ]; then
    echo "Usage: sh vpn_setup.sh <CN:user> <CN:DNS>"
    exit 1
fi

echo "CN=$1@$2"
exit 1


sudo apt-get update


# install
sudo apt-get install -y strongswan


# Private key for CA
ipsec pki --gen --type rsa --size 4096 --outform pem > /etc/ipsec.d/private/ca-key.pem
ipsec pki --self --ca --lifetime 3650 --in /etc/ipsec.d/private/ca-key.pem --type rsa --dn "CN=$2" --outform pem > /etc/ipsec.d/cacerts/ca-cert.pem


# Creating a server certificate
ipsec pki --gen --type rsa --size 4096 --outform pem > /etc/ipsec.d/private/server-key.pem

ipsec pki --pub --in /etc/ipsec.d/private/server-key.pem --type rsa \
    | ipsec pki --issue --lifetime 3650 \
    --cacert /etc/ipsec.d/cacerts/ca-cert.pem \
    --cakey /etc/ipsec.d/private/ca-key.pem \
    --dn "CN=$2" --san "$2" \
    --flag serverAuth --flag ikeIntermediate --outform pem /etc/ipsec.d/certs/server-cert.pem


# Creating a client certificate
ipsec pki --gen --type rsa --size 4096 --outform pem /etc/ipsec.d/private/client-key.pem
chmod 600 /etc/ipsec.d/private/client-key.pem

ipsec pki --pub --in /etc/ipsec.d/private/client-key.pem --type rsa \
    | ipsec pki --issue --lifetime 3650 \
    --cacert /etc/ipsec.d/cacerts/ca-cert.pem \
    --cakey /etc/ipsec.d/private/ca-key.pem \
    --dn "CN=$1@$2" --san "$1@$2" \
    --outform pem /etc/ipsec.d/certs/client-cert.pem

openssl pkcs12 -export -inkey /etc/ipsec.d/private/client-key.pem \
    -in /etc/ipsec.d/certs/client-cert.pem -name "$1 VPN client certificate" \
    -certfile /etc/ipsec.d/certs/server-cert.pem \
    -caname "Root CA" -out client.p12


# ipsec.conf