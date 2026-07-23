#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -euo pipefail

apt-get update -y
apt-get install -y curl unzip qrencode jq

# AWS CLI v2
curl -sS "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install
rm -rf /tmp/awscliv2.zip /tmp/aws

# Xray-core (latest release)
XRAY_VERSION=$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases/latest | jq -r .tag_name)
curl -sSL -o /tmp/xray.zip "https://github.com/XTLS/Xray-core/releases/download/$XRAY_VERSION/Xray-linux-64.zip"
mkdir -p /usr/local/bin/xray
unzip -q /tmp/xray.zip -d /usr/local/bin/xray
chmod +x /usr/local/bin/xray/xray
rm -f /tmp/xray.zip

XRAY_BIN=/usr/local/bin/xray/xray

# Идентификаторы
UUID=$("$XRAY_BIN" uuid)
KEYS=$("$XRAY_BIN" x25519)

PRIVATE_KEY=$(echo "$KEYS" | awk -F': ' '/^Private[Kk]ey/ {print $2}')
PUBLIC_KEY=$(echo "$KEYS" | awk -F': ' '/^(Public[Kk]ey|Password)/ {print $2}')
SHORT_ID=$(openssl rand -hex 8)

SERVER_IP=$(curl -s https://checkip.amazonaws.com)
DEST="${reality_dest}"

mkdir -p /usr/local/etc/xray

cat > /usr/local/etc/xray/config.json <<EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
      "listen": "0.0.0.0",
      "port": ${xray_port},
      "protocol": "vless",
      "settings": {
        "clients": [
          { "id": "$UUID", "flow": "xtls-rprx-vision" }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "show": false,
          "dest": "$DEST:443",
          "xver": 0,
          "serverNames": ["$DEST"],
          "privateKey": "$PRIVATE_KEY",
          "shortIds": ["$SHORT_ID"]
        }
      }
    }
  ],
  "outbounds": [
    { "protocol": "freedom" },
    { "protocol": "blackhole", "tag": "blocked" }
  ]
}
EOF

cat > /etc/systemd/system/xray.service <<EOF
[Unit]
Description=Xray Service
After=network.target

[Service]
ExecStart=$XRAY_BIN run -config /usr/local/etc/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now xray

# Клиентская ссылка (VLESS URI, импортируется в v2rayN/v2rayNG/NekoRay/Xray напрямую или через QR)
CLIENT_URI="vless://$UUID@$SERVER_IP:${xray_port}?encryption=none&flow=xtls-rprx-vision&security=reality&sni=$DEST&fp=chrome&pbk=$PUBLIC_KEY&sid=$SHORT_ID&type=tcp&headerType=none#${client_name}"

echo "$CLIENT_URI" > "/root/xray-client-${client_name}.txt"
qrencode -t ansiutf8 "$CLIENT_URI" > "/root/xray-client-${client_name}.qr.txt" || true

if command -v aws &>/dev/null && aws sts get-caller-identity &>/dev/null; then
    aws ssm put-parameter \
      --name "/vpn/client-config" \
      --value "$CLIENT_URI" \
      --type SecureString \
      --overwrite \
      --region ${region}
else
    echo "AWS SSM недоступен — креды клиента только в /root/xray-client-${client_name}.txt"
fi
