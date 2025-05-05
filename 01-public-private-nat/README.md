# Secure VPC Terraform Lab

## 📌 Overview

This project provisions a secure two-tier AWS VPC architecture using Terraform. It includes:

- A **public subnet** with a **bastion host** (EC2) to securely access internal resources.
- A **private subnet** with an EC2 instance accessible only via the bastion.
- A **NAT Gateway** for internet access from private resources.
- Modular, reusable Terraform code organized by function (VPC, networking, EC2).
- A fully automated setup and teardown experience via `setup.sh` and `cleanup.sh`.

---

## 🧰 What’s Deployed

- 1x VPC (`10.0.0.0/16`)
- 1x Internet Gateway
- 1x NAT Gateway (Elastic IP)
- 1x Public Subnet (Bastion EC2)
- 1x Private Subnet (Private EC2)
- Route Tables and Associations
- Two Security Groups (bastion, private)
- Agent forwarding and IMDSv2 security
- Pre-commit security and formatting hooks

---

## ✅ Prerequisites

Ensure the following are installed before launching the lab:

| Tool           | Purpose                                  | Install Command (Linux/macOS)             |
|----------------|------------------------------------------|--------------------------------------------|
| Terraform ≥1.6 | Infrastructure provisioning              | `brew install terraform` or manual         |
| AWS CLI        | Auth + API access to AWS                 | `brew install awscli`                      |
| SSH agent      | Required for forwarding to private host  | Usually pre-installed                      |
| tfsec          | Security scanning                        | `brew install tfsec` or manual download    |
| tflint         | Terraform linter                         | `brew install tflint`                      |
| pre-commit     | Hook runner for tfsec, tflint, fmt       | `pip install pre-commit` or via package manager |

🛠 **Note:** The `setup.sh` script will prompt for and confirm required variables, including your IP, region, AMI, and SSH key. You must configure your AWS credentials first (SSO or IAM user).

---

## 🚀 Usage

### Launch the lab

```bash
chmod +x setup.sh
./setup.sh
```

The script will:
- Validate prerequisites
- Confirm input values (region, instance type, AMI, SSH key)
- Auto-detect your public IP and inject it into terraform.tfvars
- Run terraform init, validate, and apply
- SSH into the bastion with agent forwarding ready

### Destroy the lab

```bash
chmod +x cleanup.sh
./cleanup.sh
```

cleanup.sh can be run independently or from setup.sh to destroy all resources.

## 🧪 Use Cases

- Practice SSH agent forwarding and EC2 access patterns
- Demonstrate public/private subnet isolation
- Build on a real-world Terraform module structure
- Integrate Terraform with security tools (tfsec, tflint, etc.)

## 🛡️ Security Notes

- ✅ Enforces IMDSv2 for EC2 instances (http_tokens = "required")
- ✅ Separate Security Groups for bastion and private hosts
- ✅ SSH agent forwarding configured via user_data
- ✅ Tags applied via merge(var.tags, {...})

⚠️ Lab-Only Defaults

This repo is safe for demos and labs, but you should harden it before production:

| Lab Behavior                       | Production Recommendation                       |
| ---------------------------------- | ----------------------------------------------- |
| SSH allowed only from your IP      | In production, use VPN or bastion subnet CIDRs    |
| No VPC Flow Logs                   | Enable for auditing and troubleshooting         |
| NAT Gateway always-on              | Use scheduled resources or instance-based NAT   |
| No IAM roles or S3 logging buckets | Add least-privilege IAM and centralized logs    |
| Static SSH key in `tfvars`         | Use EC2 Instance Connect or AWS Secrets Manager |

## 📈 Transition to Production (Optional Enhancements)

To prepare this project for production use, consider:

✅ Enable VPC Flow Logs for visibility (note: incurs CloudWatch costs)
✅ Add an S3 logging bucket for VPC/NAT/CloudTrail
✅ Create an IAM role for EC2 and attach it via iam_instance_profile
✅ Move secrets and AMI IDs to SSM Parameter Store
✅ Enable EC2 Instance Connect instead of SSH keys

## 📦 Project Layout

```
secure-vpc-terraform/
├── 01-public-private-nat/
│   ├── main.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   ├── variables.tf
│   ├── setup.sh / cleanup.sh
│   └── versions.tf
└── 00-modules/
    ├── ec2/
    ├── networking/
    └── vpc/
```

Each module follows the structure: *_tf, *_variables.tf, *_outputs.tf, *_versions.tf.

## ✅ Pre-Commit Hooks

Hooks automatically run:

- terraform fmt
- terraform validate
- tflint
- tfsec

To enable:
```pre-commit install```

To run manually:
```pre-commit run --all-files```

## 📄 License

This project is licensed under the MIT License. See [LICENSE](https://github.com/Alexbeav/secure-vpc-terraform/blob/main/LICENSE) for details.

## 🏷️ Version

v1.0 — Initial stable release.
