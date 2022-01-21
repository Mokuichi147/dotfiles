#!/bin/sh

if [ $# -ne 2 ]; then
    echo "Usage: sh vpn_setup.sh <CN:user> <CN:DNS>"
    exit 1
fi

echo "CN=$1@$2"


sudo apt-get update


# install
sudo apt-get install -y strongswan strongswan-pki strongswan-starter


# Preparing for backup
if [ ! -e ~/vpntemp ]; then
    mkdir ~/vpntmp
    sudo cp -r /etc/ipsec.d ~/vpntemp
    sudo cp /etc/ipsec.conf ~/vpntemp
    sudo cp /etc/ipsec.secrets ~/vpntemp
    sudo chmod 600 ~/vpntemp
else
    :
fi


# Private key for CA
ipsec pki --gen --type rsa --size 4096 --outform pem > sudo tee /etc/ipsec.d/private/ca-key.pem
ipsec pki --self --ca --lifetime 3650 --in /etc/ipsec.d/private/ca-key.pem --type rsa --dn "CN=$2" --outform pem > sudo tee /etc/ipsec.d/cacerts/ca-cert.pem


# Creating a server certificate
ipsec pki --gen --type rsa --size 4096 --outform pem > sudo tee /etc/ipsec.d/private/server-key.pem

sudo ipsec pki --pub --in /etc/ipsec.d/private/server-key.pem --type rsa \
    | ipsec pki --issue --lifetime 3650 \
    --cacert /etc/ipsec.d/cacerts/ca-cert.pem \
    --cakey /etc/ipsec.d/private/ca-key.pem \
    --dn "CN=$2" --san "$2" \
    --flag serverAuth --flag ikeIntermediate --outform pem /etc/ipsec.d/certs/server-cert.pem


# Creating a client certificate
ipsec pki --gen --type rsa --size 4096 --outform pem > sudo tee /etc/ipsec.d/private/client-key.pem
sudo chmod 600 /etc/ipsec.d/private/client-key.pem

sudo ipsec pki --pub --in /etc/ipsec.d/private/client-key.pem --type rsa \
    | ipsec pki --issue --lifetime 3650 \
    --cacert /etc/ipsec.d/cacerts/ca-cert.pem \
    --cakey /etc/ipsec.d/private/ca-key.pem \
    --dn "CN=$1@$2" --san "$1@$2" \
    --outform pem /etc/ipsec.d/certs/client-cert.pem

sudo openssl pkcs12 -export -inkey /etc/ipsec.d/private/client-key.pem \
    -in /etc/ipsec.d/certs/client-cert.pem -name "$1 VPN client certificate" \
    -certfile /etc/ipsec.d/certs/server-cert.pem \
    -caname "Root CA" -out client.p12


# ipsec.conf
echo '# ipsec.conf - strongSwan IPsec configuration file
config setup
    charondebug="cfg 2, dmn 2, ike 2, net 2"

# Default configuration options, used below if an option is not specified.
# See: https://wiki.strongswan.org/projects/strongswan/wiki/ConnSection
conn %default

    # Use IKEv2 by default
    keyexchange=ikev2

    # Prefer modern cipher suites that allow PFS (Perfect Forward Secrecy)
    ike=aes128-sha256-ecp256,aes256-sha384-ecp384,aes128-sha256-modp2048,aes128-sha1-modp2048,aes256-sha384-modp4096,aes256-sha256-modp4096,aes256-sha1-modp4096,aes128-sha256-modp1536,aes128-sha1-modp1536,aes256-sha384-modp2048,aes256-sha256-modp2048,aes256-sha1-modp2048,aes128-sha256-modp1024,aes128-sha1-modp1024,aes256-sha384-modp1536,aes256-sha256-modp1536,aes256-sha1-modp1536,aes256-sha384-modp1024,aes256-sha256-modp1024,aes256-sha1-modp1024!
    esp=aes128gcm16-ecp256,aes256gcm16-ecp384,aes128-sha256-ecp256,aes256-sha384-ecp384,aes128-sha256-modp2048,aes128-sha1-modp2048,aes256-sha384-modp4096,aes256-sha256-modp4096,aes256-sha1-modp4096,aes128-sha256-modp1536,aes128-sha1-modp1536,aes256-sha384-modp2048,aes256-sha256-modp2048,aes256-sha1-modp2048,aes128-sha256-modp1024,aes128-sha1-modp1024,aes256-sha384-modp1536,aes256-sha256-modp1536,aes256-sha1-modp1536,aes256-sha384-modp1024,aes256-sha256-modp1024,aes256-sha1-modp1024,aes128gcm16,aes256gcm16,aes128-sha256,aes128-sha1,aes256-sha384,aes256-sha256,aes256-sha1!

    # Dead Peer Discovery
    dpdaction=clear
    dpddelay=300s

    # Do not renegotiate a connection if it is about to expire
    rekey=no

    # Server side
    left=%any
    leftsubnet=0.0.0.0/0
    leftcert=server-cert.pem

    # Client side
    right=%any
    rightdns=8.8.8.8,8.8.4.4
    rightsourceip=%dhcp

# IKEv2: Newer version of the IKE protocol
conn IPSec-IKEv2
    keyexchange=ikev2
    auto=add

# IKEv2-EAP
conn IPSec-IKEv2-EAP
    also="IPSec-IKEv2"
    rightauth=eap-mschapv2
    rightsendcert=never
    eap_identity=%any

# IKEv1 (Cisco-compatible version)
conn CiscoIPSec
    keyexchange=ikev1
    # forceencaps=yes
    rightauth=pubkey
    rightauth2=xauth
    auto=add' | sudo tee /etc/ipsec.conf


# ipsec.secrets
read -p "VPN Password: " pass
echo ': RSA "server-key.pem"
'$1' : EAP "'$pass'"' | sudo tee /etc/ipsec.secrets


# port
sudo ufw allow 500,4500/udp
sudo ufw reload


# start vpn
sudo systemctl enable strongswan-starter
sudo systemctl restart strongswan-starter


# end
echo "/etc/ipsec.d/cacerts/client-cert.pem"
sudo cat /etc/ipsec.d/certs/client-cert.pem