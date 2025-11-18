#!/bin/bash
echo "appling terraform"
cd terraform && terraform apply --auto-approve
tee -a ../ansible/inventory.ini > /dev/null <<EOF
['hosts]
$(echo $(terraform output) | awk -F'"' '{print $2}')
EOF

echo "starting ansible"
cd ../ansible
# ansible myhosts -m ping -i inventory.ini