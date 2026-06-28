#!/bin/bash
set -e

if [ ! -f terraform.tfstate ]; then
    echo "Nothing to destroy"
    exit 1
fi

terraform destroy --auto-approve
rm -f terraform.tfstate terraform.tfstate.backup
rm -f wg0-client.conf

echo "Done"
