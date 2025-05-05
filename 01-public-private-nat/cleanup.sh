#!/usr/bin/env bash
set -euo pipefail

YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RED='\033[1;31m'
RESET='\033[0m'

echo -e "${YELLOW}⚠️  This will destroy all resources in the current Terraform project.${RESET}"
read -rp "Are you sure you want to continue? [y/N]: " confirm

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo -e "${RED}❌ Cleanup aborted.${RESET}"
  exit 1
fi

if [[ ! -f "main.tf" ]]; then
  echo -e "${RED}❌ main.tf not found in this directory. Are you in the right Terraform folder?${RESET}"
  exit 1
fi

echo -e "${YELLOW}🧨 Running 'terraform destroy'...${RESET}"
terraform destroy -auto-approve

read -rp "🧹 Do you want to delete all local Terraform state files (.terraform/, .tfstate)? [y/N]: " clean_local
if [[ "$clean_local" =~ ^[Yy]$ ]]; then
  echo -e "${YELLOW}🧹 Cleaning up local Terraform files...${RESET}"
  rm -rf .terraform terraform.tfstate terraform.tfstate.backup .terraform.lock.hcl
  echo -e "${GREEN}✅ Local state cleaned.${RESET}"
else
  echo -e "${YELLOW}📁 Skipping local cleanup.${RESET}"
fi

echo -e "${GREEN}✅ Cleanup complete.${RESET}"
