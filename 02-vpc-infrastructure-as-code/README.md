# Project 2: Building a VPC Using Infrastructure as Code

- A production-grade AWS VPC built entirely with Terraform, with security as a
first-class concern. 
- This project demonstrates how to design and implement
a three-tier network architecture following defence in depth principles.

## Architecture Overview
```
            Internet
                │
                ▼
        Internet Gateway
                │
                ▼
┌─────────────────────────────────────┐
│         PUBLIC TIER                 │
│  10.0.1.0/24   │   10.0.2.0/24      │
│  ap-south-1a   │   ap-south-1b      │
│  ALB, Bastion, NAT Gateway          │
└─────────────────────────────────────┘
                │
                ▼ 
    (via NAT for outbound only)
┌─────────────────────────────────────┐
│         PRIVATE TIER                │
│  10.0.10.0/24  │   10.0.20.0/24     │
│  ap-south-1a   │   ap-south-1b      │
│  Application Servers                │
└─────────────────────────────────────┘
                 │
                 ▼ 
     (no internet access)
┌─────────────────────────────────────┐
│           DATA TIER                 │
│  10.0.100.0/24 │   10.0.200.0/24    │
│  ap-south-1a   │   ap-south-1b      │
│  Databases, Sensitive Data          │
└─────────────────────────────────────┘
```

## What Gets Built

| Resource | Count | Purpose |
|----------|-------|---------|
| VPC | 1 | Isolated network (10.0.0.0/16) |
| Subnets | 6 | Public, private, and data tiers across 2 AZs |
| Internet Gateway | 1 | Public internet access |
| NAT Gateway | 1 | Outbound-only internet for private subnets |
| Elastic IP | 1 | Static IP for NAT Gateway |
| Route Tables | 3 | One per tier with appropriate routes |
| Security Groups | 4 | ALB, App, Database, Bastion |
| Network ACLs | 3 | Subnet-level stateless controls |
| VPC Endpoints | 2 | Private S3 and DynamoDB access |
| VPC Flow Logs | 2 | CloudWatch (real time) and S3 (archive) |
| IAM Role | 1 | Flow logs write permission to CloudWatch |
| S3 Bucket | 1 | Long term flow log storage |
| CloudWatch Log Group | 1 | Real time flow log monitoring |

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with credentials
- An AWS account with IAM permissions for VPC, IAM, S3, and CloudWatch

## Project Structure
```
02-vpc-infrastructure-as-code/
├── README.md
├── terraform/
│   ├── main.tf                # Provider and backend config
│   ├── vpc.tf                 # VPC and subnets
│   ├── routing.tf             # Route tables and associations
│   ├── security_groups.tf     # Security group definitions
│   ├── nacls.tf               # Network ACL rules
│   ├── nat.tf                 # NAT Gateway configuration
│   ├── endpoints.tf           # VPC Endpoints for AWS services
│   ├── flow_logs.tf           # VPC Flow Logs configuration
│   ├── variables.tf           # Input variables
│   ├── outputs.tf             # Output values
│   └── terraform.tfvars       # Variable values
└── docs/
    ├── architecture.md        # Detailed architecture explanation
    └── security-decisions.md  # Why each decision was made
```

## Usage

### Deploy
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### View Outputs
```bash
terraform output
```

### Destroy (Important — destroys all resources and stops billing)
```bash
terraform destroy
```

## Security Design

### Defence in Depth

Every tier has two independent security layers:

1. **Network ACL** — stateless, subnet-level, evaluated first
2. **Security Group** — stateful, resource-level, evaluated second

An attacker must defeat both layers independently to move between tiers.

### Traffic Flow

**Inbound user request:**
```
Internet → IGW → ALB (public) → App Server (private) → Database (data)
```

**Outbound server traffic:**
```
App Server → NAT Gateway → IGW → Internet
```

**Data tier:**
```
Database → no internet route → completely isolated
```

### Security Group Chain
```
ALB-SG (443/80 from internet)
    └── App-SG (8080 from ALB-SG only)
            └── DB-SG (5432 from App-SG only)
```

App and database security groups reference each other by security group ID,
not CIDR blocks. This means only instances with the correct security group
attached can communicate — not just any instance in the subnet CIDR.

### Network ACL Rules

| Tier | Inbound | Outbound |
|------|---------|----------|
| Public | 443, 80, 22, ephemeral | 443, 80, ephemeral |
| Private | 8080 from VPC, ephemeral | 443, 80, ephemeral to VPC |
| Data | 5432 from private subnets only | ephemeral to private subnets only |

### VPC Flow Logs

All accepted and rejected traffic is logged to two destinations:

- **CloudWatch** — near real time monitoring and alerting
- **S3** — long term archive for forensic analysis with Athena

## Cost Considerations

Most resources in this project are free. The only billable resources are:

| Resource | Cost |
|----------|------|
| NAT Gateway | ~$0.045/hr + $0.045/GB data |
| VPC Flow Logs | ~$0.50/GB ingested to CloudWatch |
| S3 Storage | ~$0.023/GB/month |

For a short demo deployment (a few hours), total cost is typically under $1.
Always run `terraform destroy` when finished to stop all billing immediately.

## Key Concepts Demonstrated

- **Infrastructure as Code** — entire network defined in version-controlled Terraform
- **Defence in depth** — multiple independent security layers at every tier
- **Least privilege** — security groups reference each other, not broad CIDRs
- **Network segmentation** — three isolated tiers with explicit, minimal connectivity
- **Zero internet access for data** — data subnets have no default route
- **Private AWS service access** — S3 and DynamoDB reachable without internet via endpoints
- **Full visibility** — all traffic metadata captured via flow logs

## Further Reading

- [AWS VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Network Firewall](https://docs.aws.amazon.com/network-firewall/latest/developerguide/what-is-aws-network-firewall.html)

---