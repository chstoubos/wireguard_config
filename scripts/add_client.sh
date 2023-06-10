#!/bin/bash

set -e

# if [ "$EUID" -ne 0 ]; then
#     echo "Run as root"
#     exit 1
# fi

if [ $# -ne 2 ]; then
    echo -e "Usage:\n$0 <peer_name> <vpn_ip>";
    exit 1;
fi

WIREGUARD_PATH="/etc/wireguard"
WIREGUARD_CLIENTS_PATH="$WIREGUARD_PATH/clients"

peer_name=$1
peer_ip=$2
peer_path="$WIREGUARD_CLIENTS_PATH/$peer_name"

if [ -d "$peer_path" ]; then
    echo "Client $peer_name already exists"
    exit 1
else
    echo "Creating new client in $peer_path"
    mkdir -p $peer_path
fi

peer_conf_file="$peer_path/$peer_name.conf"
server_conf_file="$WIREGUARD_PATH/wg0.conf"
peer_private_key_file="$peer_path/private.key"
peer_public_key_file="$peer_path/public.key"

echo "Generating private/public key pair in $peer_path"
wg genkey | tee $peer_private_key_file | wg pubkey > $peer_public_key_file

# Change permissions for peer private key to only allow root for rw
chmod 600 $peer_private_key_file

peer_private_key=$(<$peer_private_key_file)
peer_public_key=$(<$peer_public_key_file)
server_public_key=$(<$WIREGUARD_PATH/public.key)

echo "Creating peer config file: $peer_conf_file"
# Create peer config file
touch $peer_conf_file
cat <<EOF > $peer_conf_file
[Interface]
PrivateKey = $peer_private_key
Address = $peer_ip/32

[Peer]
PublicKey = $server_public_key
Endpoint = chstoubos.dedyn.io:51820
AllowedIPs = 10.6.0.0/24, 192.168.1.0/24
PersistentKeepalive = 25
EOF

echo "Adding peer to server config."
cat <<EOF >> $server_conf_file

[Peer]
# $peer_name
PublicKey = $peer_public_key
AllowedIPs = $peer_ip/32
EOF

echo -e "QR code for $peer_conf_file\n"
qrencode -t ansiutf8 < $peer_conf_file

echo -e "\nRestarting wireguard server"
# systemctl daemon-reload
# systemctl systemctl restart wg-quick@wg0.service
echo "Done!"
