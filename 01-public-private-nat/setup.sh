#!/usr/bin/env bash
set -euo pipefail

PROJECT_NAME="Scenario 01: Public + Private NAT"
TFVARS="terraform.tfvars"
KEY_PATH="$HOME/.ssh/lab-key.pem"

# Colors
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RESET='\033[0m'

# Detect public IP
detect_public_ip() {
  curl -s https://checkip.amazonaws.com || curl -s https://api.ipify.org
}

# Reusable SSH agent setup
setup_ssh_agent() {
  if ! ssh-add -l >/dev/null 2>&1; then
    echo -e "${YELLOW}⚙️  Starting SSH agent and adding key...${RESET}"
    eval "$(ssh-agent -s)"
    ssh-add "$KEY_PATH"
  fi

  if ! ssh-add -L | grep -q "$(ssh-keygen -y -f "$KEY_PATH" 2>/dev/null)"; then
    echo "❌ SSH key $KEY_PATH not loaded. Aborting."
    exit 1
  fi
}

# Check required tools
check_prerequisites() {
  echo -e "${YELLOW}🔍 Validating prerequisites...${RESET}"
  echo -e "${GREEN}🌍 Detected public IP: $(detect_public_ip)/32${RESET}"
  REQUIRED_CMDS=(terraform aws ssh-keygen curl jq)
  for cmd in "${REQUIRED_CMDS[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      echo "❌ Missing required command: $cmd"
      echo "Please install it before continuing."
      exit 1
    fi
  done

  setup_ssh_agent

  echo -e "${GREEN}✅ All required tools are installed.${RESET}"
}

print_saved_ip() {
  if grep -q "^my_ip" "$TFVARS"; then
    SAVED_IP=$(grep "^my_ip" "$TFVARS" | cut -d'"' -f2)
    echo -e "${GREEN}🌍 Public IP currently set in $TFVARS: $SAVED_IP${RESET}"
  else
    echo -e "${YELLOW}⚠️ No 'my_ip' entry found in $TFVARS.${RESET}"
  fi
}

# Handle tfvars
prepare_tfvars() {
  missing_fields=()
  if [[ -f "$TFVARS" ]]; then
    echo -e "${YELLOW}🔍 Found existing $TFVARS, checking for required variables...${RESET}"
    for var in key_name ami_id my_ip instance_type aws_region; do
      if ! grep -q "$var" "$TFVARS"; then
        missing_fields+=("$var")
      fi
    done
  else
    echo -e "${YELLOW}⚠️ $TFVARS not found, creating...${RESET}"
    touch "$TFVARS"
    missing_fields=(key_name ami_id my_ip instance_type aws_region)
  fi

  if [[ ${#missing_fields[@]} -gt 0 ]]; then
    echo "🔧 Filling in missing variables:"
    for var in "${missing_fields[@]}"; do
      if [[ "$var" == "my_ip" ]]; then
        DETECTED_IP=$(detect_public_ip)
        echo "my_ip = \"${DETECTED_IP}/32\"" >> "$TFVARS"
        echo -e "${GREEN}🌍 Detected public IP: ${DETECTED_IP}/32 — used for security group.${RESET}"
      elif [[ "$var" == "aws_region" ]]; then
        read -rp "  ➤ Enter AWS region [eu-west-1]: " region
        region="${region:-eu-west-1}"
        echo "aws_region = \"$region\"" >> "$TFVARS"
      else
        read -rp "  ➤ Enter value for $var: " val
        echo "$var = \"$val\"" >> "$TFVARS"
      fi
    done
  fi

  echo -e "${GREEN}✅ $TFVARS is complete.${RESET}"
}

# Handle SSH key
prepare_ssh_key() {
  if [[ -f "$KEY_PATH" ]]; then
    echo -e "${GREEN}✅ SSH key found: $KEY_PATH${RESET}"
  else
    echo -e "${YELLOW}⚠️ SSH key not found at $KEY_PATH${RESET}"
    read -rp "Generate new SSH key pair and import to AWS as 'lab-key'? [y/N]: " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      ssh-keygen -t rsa -b 2048 -f "$KEY_PATH" -N ""
      echo "📤 Importing public key to AWS..."
      aws ec2 import-key-pair \
        --key-name "lab-key" \
        --public-key-material "fileb://${KEY_PATH}.pub"
      echo -e "${GREEN}✅ Key imported to AWS EC2 Key Pairs.${RESET}"
    else
      echo "❌ SSH key is required. Aborting."
      exit 1
    fi
  fi
}

# Launch lab
launch_lab() {
  echo -e "${YELLOW}🚀 Launching Terraform lab...${RESET}"
  terraform init
  terraform plan
  read -rp "Apply Terraform plan? [y/N]: " apply
  if [[ "$apply" =~ ^[Yy]$ ]]; then
    terraform apply
  fi
}

# Updated connect_to_bastion
connect_to_bastion() {
  echo -e "${YELLOW}🔐 Preparing SSH environment...${RESET}"
  setup_ssh_agent

  if ! PUBLIC_IP=$(terraform output -raw public_ip 2>/dev/null); then
    echo "❌ Could not retrieve public IP. Is the lab deployed?"
    return 1
  fi

  echo -e "${GREEN}➡️  Connecting to: ubuntu@$PUBLIC_IP${RESET}"
  ssh -A -i "$KEY_PATH" "ubuntu@$PUBLIC_IP"
}

# Updated review_and_confirm_tfvars
review_and_confirm_tfvars() {
  echo -e "${YELLOW}🔍 Reviewing existing values in $TFVARS...${RESET}"

  declare -A vars=(
    [key_name]="Key Pair Name"
    [ami_id]="AMI ID"
    [my_ip]="Your Public IP"
    [instance_type]="EC2 Instance Type"
    [aws_region]="AWS Region"
  )

  FREE_TIER_INSTANCES=("t2.micro" "t3.micro")

  for var in "${!vars[@]}"; do
    current=$(grep "^$var" "$TFVARS" | cut -d'"' -f2 || echo "")
    if [[ -z "$current" ]]; then
      echo "$var = \"\"" >> "$TFVARS"
    fi
    read -rp "➤ ${vars[$var]} [$current]: " new
    new="${new:-$current}"
    sed -i "s|^$var.*|$var = \"$new\"|" "$TFVARS"

    if [[ "$var" == "instance_type" && ! " ${FREE_TIER_INSTANCES[@]} " =~ " $new " ]]; then
      echo -e "${YELLOW}⚠️ WARNING: '$new' is not Free Tier eligible. Charges may apply.${RESET}"
    fi
  done

  echo -e "${GREEN}✅ Variables updated.${RESET}"
}

# Destroy lab function
destroy_lab() {
  echo -e "${YELLOW}🧨 Destroying Terraform lab...${RESET}"
  terraform destroy -auto-approve
}

# Menu
while true; do
  echo -e "\n${YELLOW}==== $PROJECT_NAME ====${RESET}"
  echo "1) ✅ Validate prerequisites"
  echo "2) 🔄 Review & confirm Terraform variables"
  echo "3) 🚀 Launch lab"
  echo "4) 🔐 Connect to bastion"
  echo "5) 🧨 Destroy lab"
  echo "q) ❌ Quit"
  read -rp "Choose an option: " choice

  case "$choice" in
    1)
      check_prerequisites
      prepare_tfvars
      prepare_ssh_key
      print_saved_ip
      ;;
    2)
      review_and_confirm_tfvars
      ;;
    3)
      check_prerequisites
      prepare_tfvars
      prepare_ssh_key
      print_saved_ip
      launch_lab
      ;;
    4)
      connect_to_bastion
      ;;
    5)
      destroy_lab
      ;;
    q|Q)
      echo -e "${GREEN}Goodbye!${RESET}"
      break
      ;;
    *)
      echo "❌ Invalid choice. Please try again."
      ;;
  esac
done