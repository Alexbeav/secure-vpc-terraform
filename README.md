# Secure VPC Terraform

## 🧭 Overview

This repository contains modular, production-aware Terraform labs focused on securely deploying virtual private cloud (VPC) environments on AWS.

Each scenario is designed as a self-contained lab with reusable modules, automated setup scripts, and security best practices built-in.

---

## 📁 Scenarios

| Folder                    | Description                                                              |
|---------------------------|---------------------------------------------------------------------------|
| `01-public-private-nat/`  | Secure VPC with public (bastion) + private (app) subnets, NAT gateway    |
| *(planned)*               | Additional scenarios (e.g. VPN access, VPC endpoints, logging, S3-only)  |

---

## 🧱 Shared Modules

Modules under `00-modules/` are designed for reuse across scenarios:

- `vpc/` — VPC, DNS support, flow log-ready
- `networking/` — Subnets, route tables, gateways, security groups
- `ec2/` — Bastion and private instance deployment with tagging, user_data, IMDSv2

---

## 🚀 Usage

Each scenario has its own `setup.sh` and `cleanup.sh` to simplify launching and tearing down labs.

Example:

```bash
cd 01-public-private-nat
./setup.sh    # provision infrastructure
./cleanup.sh  # destroy infrastructure
```

## 📦 Tooling

All scenarios and modules are tested with:

- ✅ terraform fmt, validate, and tflint
- ✅ tfsec for security scanning
- ✅ pre-commit for consistent formatting and checks

To enable pre-commit:
```bash
pre-commit install
pre-commit run --all-files
```

## 🛠 Requirements

- Terraform ≥ 1.6
- AWS CLI (configured via IAM or SSO)
- SSH key pair (e.g. lab-key.pem)
- pre-commit, tflint, tfsec installed
Each scenario prompts for confirmation and shows variable values before apply.

## 🎯 Goals
This repo is designed to help:
- Network & Cloud Engineers practice VPC design and automation
- DevOps Engineers build reusable, security-focused Terraform modules
- Hiring managers or recruiters assess Terraform and IaC skills with real-world structure

## 📖 License
This repository is licensed under the MIT License. See [LICENSE](https://github.com/Alexbeav/secure-vpc-terraform/blob/main/LICENSE) for details.
