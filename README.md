# Wireguard setup

### Create private/public key pair for the server and set the appropriate permissions
```
# wg genkey | tee /etc/wireguard/private.key | wg pubkey > /etc/wireguard/public.key
# chmod 600 /etc/wireguard/private.key
```

### Enable wireguard service
```
# systemctl enable wg-quick@wg0.service
# systemctl start wg-quick@wg0.service
```

### Disable wireguard service
```
# systemctl stop wg-quick@wg0.service
# systemctl disable wg-quick@wg0.service
```

### Adding new client
```
# ./add_new_client <peer_name> <vpn_ip>
```
