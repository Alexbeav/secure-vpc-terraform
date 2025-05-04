# Scenario 01: Public + Private Subnets with NAT Gateway

## 📌 Overview
This Terraform scenario provisions a secure AWS VPC with:
- A public subnet for internet-facing resources (e.g., bastion host).
- A private subnet for internal resources (e.g., backend services).
- A NAT Gateway in the public subnet to allow the private subnet to initiate outbound internet access.

## 🧰 What’s Deployed
- 1x VPC with CIDR block (e.g. `10.0.0.0/16`)
- 1x Internet Gateway
- 1x NAT Gateway (with EIP)
- 1x Public subnet with a public EC2 instance
- 1x Private subnet with a private EC2 instance
- Route tables, associations, and security group rules

## 🧪 Use Cases
- Bastion host to SSH into private EC2
- Isolated backend resources that can update packages (via NAT)
- Demonstrating VPC segmentation best practices

## ✅ Prerequisites
- AWS CLI and Terraform installed
- IAM Identity Center / AWS credentials configured (`aws configure sso`)
- SSH key pair (`~/.ssh/lab-key.pem`) exists and matches `terraform.tfvars`
- Your IP is allowlisted for SSH in the security group

## 🚀 Usage

Creating the lab

```bash
cd 01-public-private-nat
terraform init
terraform plan
terraform apply
```

Destroying the lab
```bash
terraform destroy
```

## 🔒 Notes

- This setup is for lab/demo use — do not use these security group rules in production.
- Public EC2 has a public IP; private EC2 does not.
- NAT Gateway incurs cost even when idle.