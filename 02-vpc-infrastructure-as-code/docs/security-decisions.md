# Security Decisions

Every decision in this architecture involves a tradeoff. This document explains
what was chosen, why, and what was deliberately left out.

---

## Three-Tier Network Segmentation
- Divides the VPC into public, private, and data tiers instead of a flat network
- A flat network lets a compromised resource freely reach everything else
- Segmentation forces an attacker to move laterally one tier at a time, each step requiring additional controls to defeat

---

## Security Group Chaining Over CIDR Rules
- App and database security groups reference each other by SG ID, not subnet CIDRs
- A CIDR rule allows any resource in that IP range — an SG rule allows only resources with that specific group attached
- A compromised server in the same subnet without the correct SG cannot reach the next tier

---

## No Internet Access for Data Tier
- The data route table has no default route
- Databases have no legitimate reason to initiate or receive internet connections
- Removing the route entirely means no misconfiguration can accidentally expose them — the path simply does not exist

---

## Single NAT Gateway
- Uses one NAT Gateway in ap-south-1a instead of one per AZ
- **Tradeoff:** if ap-south-1a goes down, private subnets in ap-south-1b lose outbound internet access
- In production, one NAT Gateway per AZ eliminates this dependency
- Single gateway here is a cost decision — NAT Gateways bill hourly per instance

---

## Gateway Endpoints Over Interface Endpoints
- S3 and DynamoDB use free Gateway Endpoints
- Other AWS services (SSM, Secrets Manager, ECR) require Interface Endpoints at ~$0.01/hr each
- **Tradeoff:** those services would route through NAT instead of AWS's internal network
- In production, Interface Endpoints would be added for any frequently accessed service

---

## Flow Logs Capturing All Traffic
- Set to capture ALL traffic rather than just ACCEPT or REJECT
- Accepted traffic shows normal behaviour patterns
- Rejected traffic reveals scanning attempts and early signs of lateral movement
- Having both lets you correlate what was attempted against what succeeded

---

## Bastion SSH Locked to Single IP
- Bastion security group allows SSH only from a specific /32 IP address
- Opening SSH to 0.0.0.0/0 exposes the bastion to the entire internet
- A /32 means only one IP can attempt a connection — everything else is dropped before reaching the host
- **Note:** home and mobile ISPs change IPs periodically — if SSH stops working, update the CIDR in security_groups.tf and run terraform apply

---

## S3 Bucket Hardening for Flow Logs
- Flow logs bucket has versioning, AES256 encryption, and all public access blocks enabled
- Flow log data reveals your entire network topology — what talks to what, which ports are open, traffic volumes
- An attacker with access to this bucket could map your infrastructure without touching it
- The bucket is treated with the same sensitivity as the data it describes

---

## force_destroy on the Flow Logs Bucket
- The S3 bucket has force_destroy = true so terraform destroy can delete it cleanly
- Would never be set in production — accidentally destroying network logs would be a serious incident
- Exists here purely to make cleanup simple after the demo

---