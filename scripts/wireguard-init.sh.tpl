#!/bin/bash
export AUTO_INSTALL=y
export SERVER_PORT=${wg_port}
export CLIENT_NAME=${client_name}

curl -sS https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh | bash

aws ssm put-parameter \
  --name "/vpn/client-config" \
  --value "$(cat /home/ubuntu/wg0-client-${client_name}.conf)" \
  --type SecureString \
  --overwrite \
  --region ${region}
