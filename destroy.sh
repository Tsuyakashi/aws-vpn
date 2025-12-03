#!/bin/bash

set -e

if [ ! -f terraform/*.tfstate ]; then
    echo "Nothing to destroy"
    exit 1
fi

cd terraform
terraform destroy --auto-approve

echo "Removing .tfstate"
rm *.tfstate

cd ..

[ -f ansible/hosts ] && echo "removing hosts" && rm ansible/hosts
[ -f ansible/*.conf ] && echo "removing .conf" && rm ansible/*.conf