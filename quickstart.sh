#!/bin/bash
set -e

DIR_PATH=$PWD
PRIVATE_KEY_PATH="$DIR_PATH/terraform/keys/rsa.key"
INVENTORY_PATH="$DIR_PATH/ansible/hosts"
PLAYBOOK_SETUP_PATH="$DIR_PATH/ansible/wireguard-setup.yml"

echo "Appling terraform"
# cd terraform

if [ ! -f "$PRIVATE_KEY_PATH" ]; then
    echo "Generating rsa keys"
    mkdir -p $DIR_PATH/terraform/keys
    ssh-keygen -f $PRIVATE_KEY_PATH -t rsa -N ""
    chmod 600 $PRIVATE_KEY_PATH
fi

cd $DIR_PATH/terraform

terraform init
terraform apply --auto-approve

echo "Creating inventory for ansible"
if [ -f "$INVENTORY_PATH" ]; then
    echo "$(terraform output -raw instance_hostname)" >> $INVENTORY_PATH
else
    echo "[hosts]" > $INVENTORY_PATH
    echo "$(terraform output -raw instance_hostname)" >> $INVENTORY_PATH
fi


while ! nc -z "$(terraform output -raw instance_hostname)" 22 >/dev/null 2>&1; do
    echo "Instance didnt start yet"
    sleep 5
done


echo "Starting ansible"
cd $DIR_PATH/ansible    
ansible-playbook -i $INVENTORY_PATH $PLAYBOOK_SETUP_PATH
cd $DIR_PATH