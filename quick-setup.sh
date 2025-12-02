#!/bin/bash
set -e

! aws --version &>/dev/null && echo "AWS CLI is not installed" && exit 1
! terraform --version &>/dev/null && echo "Terraform is not installed" && exit 1
! ansible --version &>/dev/null && echo "Ansible is not installed" && exit 1

echo "Starting up"

DIR_PATH=$PWD
PRIVATE_KEY_PATH="$DIR_PATH/terraform/keys/rsa.key"
INVENTORY_PATH="$DIR_PATH/ansible/hosts"
PLAYBOOK_SETUP_PATH="$DIR_PATH/ansible/wireguard-setup.yml"

echo "Applying terraform"
# cd terraform

if [ ! -f "$PRIVATE_KEY_PATH" ]; then
    echo "Generating rsa keys"
    mkdir -p $DIR_PATH/terraform/keys
    ssh-keygen -f $PRIVATE_KEY_PATH -t rsa -N ""
    chmod 600 $PRIVATE_KEY_PATH
fi


cd $DIR_PATH/terraform
if [ ! -f $DIR_PATH/terraform/*.tfstate ]; then
    terraform init
    terraform apply --auto-approve

else
    echo "Terraform applied, skipping"
fi


while ! nc -z "$(terraform output -raw instance_hostname)" 22 >/dev/null 2>&1; do
    echo "Instance didnt start yet"
    sleep 5
done

echo "Creating inventory for ansible"
if [ -f "$INVENTORY_PATH" ]; then
    echo "$(terraform output -raw instance_hostname)" >> $INVENTORY_PATH
else
    echo "[hosts]" > $INVENTORY_PATH
    echo "$(terraform output -raw instance_hostname)" >> $INVENTORY_PATH
fi

if [ ! -f $DIR_PATH/ansible/*.conf ]; then
    echo "Starting ansible"
    cd $DIR_PATH/ansible    
    ansible-playbook -i $INVENTORY_PATH $PLAYBOOK_SETUP_PATH
    cd $DIR_PATH/
else 
    echo "Config file exists, skipping"
fi

echo "Started up."