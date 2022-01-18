#!/bin/sh

sudo apt-get update


# install
sudo apt-get install -y strongswan

# Private key for CA
ipsec pki --gen --type rsa --size 4096 --outform pem > /etc/ipsec.d/private/ca-key.pem
ipsec pki --self --ca --lifetime 3650 --in /etc/ipsec.d/private/ca-key.pem --type rsa --outform pem > /etc/ipsec.d/cacerts/ca-cert.pem

# Creating a server certificate
ipsec pki --gen --type rsa --size 4096 --outform pem > /etc/ipsec.d/private/server-key.pem
