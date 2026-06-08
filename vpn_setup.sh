#!/bin/zsh

if [ $# -ne 2 ]; then
    echo "Usage: sh vpn_setup.sh <CN:user> <CN:DNS>"
    exit 1
fi

echo "CN=$1@$2\n"


sudo apt-get update > /dev/null


# install
sudo apt-get install -y openvpn easy-rsa > /dev/null


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


# work dir
if [ ! -e ~/pki ]; then
    mkdir -p ~/pki/cacerts ~/pki/certs ~/pki/private
    sudo chmod 700 ~/pki
else
    :
fi


# Private key for CA
ipsec pki --gen --type rsa --size 4096 --outform pem > ~/pki/private/ca-key.pem
ipsec pki --self --ca --lifetime 3650 --in ~/pki/private/ca-key.pem --type rsa --dn "CN=$2" --outform pem > ~/pki/cacerts/ca-cert.pem


# Creating a server certificate
ipsec pki --gen --type rsa --size 4096 --outform pem > ~/pki/private/server-key.pem

ipsec pki --pub --in ~/pki/private/server-key.pem --type rsa \
    | ipsec pki --issue --lifetime 3650 \
    --cacert ~/pki/cacerts/ca-cert.pem \
    --cakey ~/pki/private/ca-key.pem \
    --dn "CN=$2" --san "$2" \
    --flag serverAuth --flag ikeIntermediate --outform pem > ~/pki/certs/server-cert.pem


# Creating a client certificate
ipsec pki --gen --type rsa --size 4096 --outform pem > ~/pki/private/client-key.pem
sudo chmod 600 ~/pki/private/client-key.pem

ipsec pki --pub --in ~/pki/private/client-key.pem --type rsa \
    | ipsec pki --issue --lifetime 3650 \
    --cacert ~/pki/cacerts/ca-cert.pem \
    --cakey ~/pki/private/ca-key.pem \
    --dn "CN=$1@$2" --san "$1@$2" \
    --outform pem > ~/pki/certs/client-cert.pem


sudo cp -r ~/pki/* /etc/ipsec.d/


if [ ! -e ~/pki/client.p12 ]; then
    sudo rm ~/pki/client.p12
else
    :
fi

read -s "PASS? VPN Password: "


openssl pkcs12 -export -inkey ~/pki/private/client-key.pem \
    -in ~/pki/certs/client-cert.pem -name "$1 VPN client certificate" \
    -certfile ~/pki/certs/server-cert.pem \
    -passin pass:$PASS -passout pass:$PASS \
    -caname "Root CA" -out ~/pki/client.p12


# ipsec.conf
echo '# ipsec.conf - strongSwan IPsec configuration file
config setup
    # Slightly more verbose logging. Very useful for debugging.
    charondebug="cfg 2, dmn 2, ike 2, net 2"

conn %default
    # Use IKEv2 by default
    keyexchange=ikev2

    # Prefer modern cipher suites that allow PFS (Perfect Forward Secrecy)
    ike=aes256-sha1-modp1024,aes128-sha1-modp1024,3des-sha1-modp1024!
    esp=aes256-sha256,aes256-sha1,3des-sha1!

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
    auto=add' | sudo tee /etc/ipsec.conf > /dev/null


# ipsec.secrets
echo ': RSA "server-key.pem"
'$1' : EAP "'$PASS'"' | sudo tee /etc/ipsec.secrets > /dev/null
echo ""


# port
sudo ufw allow 500,4500/udp
sudo ufw allow 50
sudo ufw reload


# start vpn
sudo systemctl enable strongswan-starter
sudo systemctl restart strongswan-starter


# end
echo "/etc/ipsec.d/cacerts/client-cert.pem"
sudo cat /etc/ipsec.d/certs/client-cert.pem