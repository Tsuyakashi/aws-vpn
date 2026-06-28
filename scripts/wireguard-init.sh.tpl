#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -euo pipefail

apt-get update -y
apt-get install -y wireguard qrencode unzip

# Устанавливаем AWS CLI v2
curl -sS "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install
rm -rf /tmp/awscliv2.zip /tmp/aws

# Генерируем ключи сервера
SERVER_PRIV_KEY=$(wg genkey)
SERVER_PUB_KEY=$(echo "$SERVER_PRIV_KEY" | wg pubkey)
CLIENT_PRIV_KEY=$(wg genkey)
CLIENT_PUB_KEY=$(echo "$CLIENT_PRIV_KEY" | wg pubkey)
PSK=$(wg genpsk)

SERVER_IP=$(curl -s https://checkip.amazonaws.com)
NIC=$(ip -4 route ls | grep default | awk '/dev/ {for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}' | head -1)

# Конфиг сервера
cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
Address = 10.66.66.1/24
ListenPort = ${wg_port}
PrivateKey = $SERVER_PRIV_KEY
PostUp = iptables -I FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o $NIC -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o $NIC -j MASQUERADE

[Peer]
PublicKey = $CLIENT_PUB_KEY
PresharedKey = $PSK
AllowedIPs = 10.66.66.2/32
EOF

# IP форвардинг
echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/wg.conf
sysctl --system

systemctl enable --now wg-quick@wg0

# Конфиг клиента
cat > /root/wg0-client-${client_name}.conf <<EOF
[Interface]
PrivateKey = $CLIENT_PRIV_KEY
Address = 10.66.66.2/32
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUB_KEY
PresharedKey = $PSK
Endpoint = $SERVER_IP:${wg_port}
AllowedIPs = 0.0.0.0/0
EOF

aws ssm put-parameter \
  --name "/vpn/client-config" \
  --value "$(cat /root/wg0-client-${client_name}.conf)" \
  --type SecureString \
  --overwrite \
  --region ${region}
