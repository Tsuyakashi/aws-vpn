#!/bin/bash
set -e

! aws --version &>/dev/null && echo "AWS CLI is not installed" && exit 1
! terraform --version &>/dev/null && echo "Terraform is not installed" && exit 1

DIR_PATH=$PWD

cd "$DIR_PATH"

if [ -z "$(terraform state list 2>/dev/null)" ]; then
    terraform init
    terraform apply --auto-approve
else
    echo "Terraform already applied, skipping"
fi

echo "Waiting for WireGuard config in SSM..."
for i in {1..20}; do
    if aws ssm get-parameter --name "/vpn/client-config" --with-decryption &>/dev/null; then
        echo "Config ready"
        break
    fi
    echo "$i. Not ready yet..."
    sleep 15
done

if ! aws ssm get-parameter --name "/vpn/client-config" --with-decryption &>/dev/null; then
    echo "Timed out waiting for config"
    exit 1
fi

aws ssm get-parameter \
    --name "/vpn/client-config" \
    --with-decryption \
    --query Parameter.Value \
    --output text > wg0-client.conf

echo "Done. Config saved to wg0-client.conf"
