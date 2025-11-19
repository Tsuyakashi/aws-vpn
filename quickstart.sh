#!/bin/bash
set -e

echo "appling terraform"
cd terraform
terraform init
terraform apply --auto-approve

echo "creating inventory for ansible"
if [ -f "../ansible/hosts" ]; then
    rm ../ansible/hosts
fi

tee -a ../ansible/hosts > /dev/null <<EOF
[hosts]
$(echo $(terraform output) | awk -F'"' '{print $2}')
EOF

# while true; do
#     if [[ "$(terraform output -raw instance_state 2>/dev/null)" == "running" ]]; then
#         echo "Instance running"
#         break
#     fi

#     echo "Instance didnt start yet"
#     sleep 10
# done
# что-то нерабочее

while ! nc -z "$(terraform output -raw instance_hostname)" 22 >/dev/null 2>&1; do
    echo "Instance didnt start yet"
    sleep 5
done


echo "starting ansible"
cd ../ansible
ansible-playbook -i hosts -i inventory.ini main.yml
