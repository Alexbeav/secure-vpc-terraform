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

print_saved_ip() {
  if grep -q "^my_ip" "$TFVARS"; then
    SAVED_IP=$(grep "^my_ip" "$TFVARS" | cut -d'"' -f2)
    echo -e "${GREEN}🌍 Public IP currently set in $TFVARS: $SAVED_IP${RESET}"
  else
    echo -e "${YELLOW}⚠️ No 'my_ip' entry found in $TFVARS.${RESET}"
  fi
}

# Start SSH agent if not already running
if ! ssh-add -l >/dev/null 2>&1; then
  echo -e "${YELLOW}⚙️  Starting SSH agent and adding key...${RESET}"
  eval "$(ssh-agent -s)"
  ssh-add "$KEY_PATH"
fi

# Confirm key is loaded
if ! ssh-add -L | grep -q "$(ssh-keygen -y -f "$KEY_PATH" 2>/dev/null)"; then
  echo "❌ SSH key $KEY_PATH not loaded. Aborting."
  exit 1
fi

  echo -e "${GREEN}✅ All required tools are installed.${RESET}"
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

connect_to_bastion() {
  echo -e "${YELLOW}🔐 Attempting to connect to bastion...${RESET}"
  if ! terraform output -json public_ip >/dev/null 2>&1; then
    echo "❌ Could not retrieve public IP. Is the lab deployed?"
    return 1
  fi

  PUBLIC_IP=$(terraform output -raw public_ip)
  echo -e "${GREEN}➡️  Connecting to: ubuntu@$PUBLIC_IP${RESET}"
  ssh -A -i "$KEY_PATH" "ubuntu@$PUBLIC_IP"
}

# Destroy lab
destroy_lab() {
  echo -e "${YELLOW}🧨 Destroying Terraform lab...${RESET}"
  terraform destroy
}

# Menu
while true; do
  echo -e "\n${YELLOW}==== $PROJECT_NAME ====${RESET}"
  echo "1) ✅ Validate prerequisites"
  echo "2) 🚀 Launch lab"
  echo "3) 🔐 Connect to bastion"
  echo "4) 🧨 Destroy lab"
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
      check_prerequisites
      prepare_tfvars
      prepare_ssh_key
      print_saved_ip
      launch_lab
      ;;
    3)
      connect_to_bastion
      ;;
    4)
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
