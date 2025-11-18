#!/bin/bash
set -e
# terraform apply DONT WORK, run urself 
echo "appling terraform"
cd terraform
# terraform init
# terraform apply --auto-approve

echo "creating inventory for ansible"
tee -a ../ansible/hosts > /dev/null <<EOF
[hosts]
$(echo $(terraform output) | awk -F'"' '{print $2}')
EOF

# also dont work yet :D

echo "starting ansible"
cd ../ansible
ansible all -i hosts -i inventory.ini -m ping 
# ansible-playbook -i hosts -i inventory.ini main.yml
