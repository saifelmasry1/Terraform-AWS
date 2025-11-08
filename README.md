# ☁️ Terraform AWS Infrastructure Project

### 🚀 Automated AWS Infrastructure Deployment using Terraform
Build a **complete cloud network** with **VPC**, **Subnets**, **Internet Gateway**, **NAT Gateway**, and **EC2** — all provisioned automatically using Terraform and stored in a remote **S3 backend**.

---

## 🧩 Overview

This project provisions a **complete AWS network** using Terraform, including **VPC**, **Subnets**, **IGW**, **NAT Gateway** (with Elastic IP), and **EC2 instance**. The state is stored remotely in **S3** for collaboration and reliability.

| Resource | Description |
|-----------|-------------|
| **VPC** | Custom 10.0.0.0/16 VPC |
| **Subnets** | Public & Private Subnets |
| **Gateways** | Internet Gateway & NAT Gateway |
| **State** | Terraform Remote State in S3 |

---

## 🧭 Features

- 🧱 Isolated **VPC** with public and private subnets
- 🌐 **IGW** for public egress, **NAT** for private egress
- 🧭 **Route Tables** with explicit associations
- 💻 Public **EC2** instance with SSH access
- ☁️ **S3 Backend** for remote state storage and locking

---

## 🗺️ Architecture Diagram

```
          
                        ┌──────────────────────────────┐
                        │          Internet            │
                        └──────────────┬───────────────┘
                                       │  (0.0.0.0/0 via IGW)
                             ┌──────────▼───────────┐
                             │   Internet Gateway   │
                             └──────────┬───────────┘
                                        │
                    ┌───────────────────▼───────────────────┐
                    │          VPC (10.0.0.0/16)            │
                    │───────────────────────────────────────│
                    │                                       │
            ┌────────────────────┐              ┌────────────────────┐
            │   Public Subnet    │              │   Private Subnet   │
            │   (10.0.1.0/24)    │              │   (10.0.2.0/24     │
            │ ┌───────────────┐  │              │ ┌───────────────┐  │
            │ │ EC2 Instance  │  │              │ │ Internal App │   │
            │ │ SG: SSH :22   │  │              │ │ Backend DB   │   │
            │ └───────┬───────┘  │              │ └──────┬────────┘  │
            │         │          │              │        │           │
            │ Route → 0.0.0.0/0  │              │ Route → 0.0.0.0/0  │
            │     via IGW        │              │     via NAT GW     │
            └─────────┼──────────┘              └────────┼───────────┘
                      │                                  │
                      └────────────┬─────────────────────┘
                                   │
                         ┌─────────▼─────────┐
                         │ NAT Gateway + EIP │
                         └───────────────────┘


```

---

## ⚙️ Setup Instructions

### 🔧 Prerequisites

- Terraform **v1.9+**
- AWS CLI configured (`aws configure`)
- Existing AWS key pair (`.pem` file)

### 🧱 Steps

```bash
# 1️⃣ Initialize Terraform
terraform init

# 2️⃣ Validate configuration
terraform validate

# 3️⃣ Preview the plan
terraform plan

# 4️⃣ Apply the configuration
terraform apply

# 5️⃣ Connect to EC2 (Ubuntu AMI example)
ssh -i ~/.ssh/<your-key>.pem ubuntu@<EC2_PUBLIC_IP>
```

---

## 📁 Project Structure

```bash
terraform-aws/
├── main.tf             # VPC, Subnets, IGW, NAT, Routes, EC2, Security Group
├── variables.tf        # Input variables
├── provider.tf         # AWS provider configuration
├── terraform.tf        # S3 backend & provider version
├── output.tf           # Outputs (IDs, IPs)
├── terraform.tfvars    # Variable values (gitignored)
└── image.png           # Optional architecture diagram
```

---

## 📤 Key Outputs

| Output | Description |
|---------|-------------|
| `vpc_id` | VPC ID created by Terraform |
| `public_subnet_id` | ID of public subnet |
| `private_subnet_id` | ID of private subnet |
| `internet_gateway_id` | IGW ID |
| `nat_gateway_ip` | NAT Gateway public IP |
| `terraform-electron-ec2_public_ip` | EC2 public IP |

---

## 🔐 Security Best Practices

- 🚫 Never commit AWS credentials or secrets in Terraform files
- 🧱 Add `.terraform/` and `*.tfstate` to `.gitignore`
- 🔒 Restrict SSH access to your own IP
- ☁️ Use S3 backend with versioning and encryption enabled

---

## 🧰 Troubleshooting

| Issue | Cause | Fix |
|--------|--------|-----|
| `InvalidBucketName` | Spaces or uppercase in S3 bucket name | Rename bucket (e.g. `terraform-state-mezo`) |
| `Permission denied (publickey)` | Wrong SSH key or username | Use correct `.pem` key and `ubuntu` user |
| Backend error | Region or permission mismatch | Align AWS region and IAM policy |
| Slow apply | NAT Gateway provisioning delay | Wait ~2 minutes (expected) |

---

## 🌱 Future Enhancements

- Add **Load Balancer (ALB)** and **Auto Scaling Group**
- Create reusable **Terraform Modules**
- Integrate monitoring with **CloudWatch** / **Grafana**
- Automate deployment with **Jenkins** or **GitHub Actions**

---

##  Author

**Saif Elmasry**  
💼 DevOps Engineer | ☁️ Cloud & IaC Specialist  
📧 [saifelmasry5968@gmail.com](mailto:saifelmasry5968@gmail.com)  
🔗 [GitHub Profile](https://github.com/saifelmasry1)

---

<h2 align="center">💜 Built with Terraform & AWS — Automated. Scalable. Secure.</h2>
