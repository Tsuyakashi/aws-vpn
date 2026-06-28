#!/bin/bash

COMMAND_ID=$(aws ssm send-command \
  --instance-ids $(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=vpn-instance" "Name=instance-state-name,Values=running" \
    --query "Reservations[0].Instances[0].InstanceId" --output text) \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=["cat /var/log/user-data.log"]' \
  --query "Command.CommandId" --output text)

sleep 5

aws ssm get-command-invocation  \
    --command-id "$COMMAND_ID" \
    --instance-id $(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=vpn-instance" "Name=instance-state-name,Values=running" \
    --query "Reservations[0].Instances[0].InstanceId" --output text) \
    --query "StandardOutputContent" --output text
