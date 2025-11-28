#!/bin/bash
set -e

echo "Appling terraform"
# cd terraform

if [ ! -f "./keys/rsa.key" ]; then
    echo "Generating rsa keys"
    ssh-keygen -f ./terraform/keys/rsa.key -t rsa -N ""
    chmod 600 ./terraform/keys/rsa.key
fi

cd terraform

terraform init
terraform apply --auto-approve

echo "Creating inventory for ansible"
if [ -f "../ansible/hosts" ]; then
    echo "$(terraform output -raw instance_hostname)" >> ../ansible/hosts
else
    echo "[hosts]" > ../ansible/hosts
    echo "$(terraform output -raw instance_hostname)" >> ../ansible/hosts
fi


while ! nc -z "$(terraform output -raw instance_hostname)" 22 >/dev/null 2>&1; do
    echo "Instance didnt start yet"
    sleep 5
done


echo "Starting ansible"
cd ../ansible
ansible-playbook -i hosts -i inventory.ini main.yml
