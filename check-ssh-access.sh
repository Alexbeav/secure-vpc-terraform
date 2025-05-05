#!/usr/bin/env bash
set -euo pipefail

KEY_PATH="$HOME/.ssh/lab-key.pem"

echo "🔍 Checking Terraform outputs..."
public_ip=$(terraform output -raw public_ip || echo "")
if [[ -z "$public_ip" ]]; then
  echo "❌ Public IP not found in Terraform outputs."
  exit 1
fi
echo "✅ Bastion public IP: $public_ip"

echo "🌍 Detecting your current public IP..."
my_ip=$(curl -s https://checkip.amazonaws.com)
echo "✅ Your public IP: $my_ip"

echo "🔐 Verifying SSH key in agent..."
if ! ssh-add -l | grep -q "$(basename "$KEY_PATH")"; then
  echo "⚙️ Adding SSH key to agent..."
  eval "$(ssh-agent -s)"
  ssh-add "$KEY_PATH"
fi

echo "📡 Checking EC2 instance's security group..."
instance_id=$(aws ec2 describe-instances \
  --filters "Name=ip-address,Values=$public_ip" \
  --query "Reservations[*].Instances[*].InstanceId" \
  --output text)

sg_id=$(aws ec2 describe-instances \
  --instance-ids "$instance_id" \
  --query "Reservations[0].Instances[0].SecurityGroups[0].GroupId" \
  --output text)

echo "✅ Instance ID: $instance_id"
echo "✅ Security Group: $sg_id"

echo "🔎 Checking if your IP is allowed in SG for port 22..."
allowed=$(aws ec2 describe-security-groups \
  --group-ids "$sg_id" \
  --query "SecurityGroups[0].IpPermissions[?FromPort==\`22\`].IpRanges[*].CidrIp" \
  --output text)

if echo "$allowed" | grep -q "${my_ip}/32"; then
  echo "✅ Your IP $my_ip/32 is allowed for SSH."
else
  echo "❌ Your IP $my_ip/32 is NOT allowed in SG. Allowed list:"
  echo "$allowed"
fi

echo "🧪 Attempting SSH..."
ssh -A -i "$KEY_PATH" "ubuntu@$public_ip"
