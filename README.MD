# Secure VPC Terraform Lab

This project provisions a basic AWS VPC using Terraform as part of a secure cloud infrastructure lab.

## Features

- VPC with customizable CIDR
- Terraform best practices (remote state, variable use, version pinning)
- GitHub-integrated, tfsec scanned

## Getting Started

```bash
terraform init
terraform plan
terraform apply

Requirements
- Terraform >= 1.4
- AWS account with IAM Identity Center
- CLI profile configured (e.g., crosstalkis-admin)