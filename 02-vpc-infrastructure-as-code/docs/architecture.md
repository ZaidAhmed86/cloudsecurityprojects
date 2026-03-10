# Architecture

## Overview

- This VPC implements a three-tier network architecture across two availability
zones in ap-south-1 (Mumbai). 
- The core philosophy is simple: every resource
lives in the least privileged network position that still allows it to do its
job. 
- Nothing gets more network access than it actually needs.

---

## Network Layout

- The VPC uses 10.0.0.0/16 as its address space, giving 65,536 available IP
addresses. 
- Each subnet is a /24, providing 256 addresses per subnet with AWS
reserving 5 per subnet for internal use.

| Subnet | CIDR | Availability Zone | Tier |
|--------|------|-------------------|------|
| public-a | 10.0.1.0/24 | ap-south-1a | Public |
| public-b | 10.0.2.0/24 | ap-south-1b | Public |
| private-a | 10.0.10.0/24 | ap-south-1a | Private |
| private-b | 10.0.20.0/24 | ap-south-1b | Private |
| data-a | 10.0.100.0/24 | ap-south-1a | Data |
| data-b | 10.0.200.0/24 | ap-south-1b | Data |

---

## Tier Design

### Public Tier
- Hosts resources that must be directly reachable from the internet — ALB, NAT Gateway, Bastion
- Internet Gateway attached here, public route table sends all external traffic through it
- Resources in this tier have public IP addresses by default

### Private Tier
- Hosts application servers — reachable only through the ALB, never directly from the internet
- No public IP addresses, no inbound internet route
- Outbound traffic routes through the NAT Gateway, which masks the server's real private IP

### Data Tier
- Hosts databases and sensitive storage — reachable only from the private tier
- Route table has no default route — no path to or from the internet in either direction
- AWS service access handled through VPC endpoints, keeping traffic within AWS's internal network

---

## Traffic Flows

### Inbound User Request
```
Internet → IGW → ALB (public) → App Server (private) → Database (data)
```
- Each tier boundary has two checkpoints — the subnet NACL and the resource security group
- A packet rejected by either never reaches its destination
- App and database security groups reference each other by SG ID, not CIDR — only correctly tagged instances can pass

### Outbound Server Traffic
```
App Server → NAT Gateway → IGW → Internet
```
- NAT Gateway replaces the server's private IP with its Elastic IP before forwarding
- The internet never sees the real address of any private subnet resource
- Data subnet resources have no outbound path at all — the route table has no default route so packets are dropped immediately

### AWS Service Access
- S3 and DynamoDB are reachable from private and data subnets via VPC Gateway Endpoints
- Traffic routes entirely within AWS's internal network
- No internet required, no NAT Gateway bandwidth consumed

---

## Security Layers

Every tier boundary has two independent controls — a Network ACL at the subnet
level and a Security Group at the resource level.

- **NACLs** are stateless and subnet-wide. Return traffic must be explicitly
  permitted using ephemeral port rules (1024-65535). Support both allow and deny.
- **Security Groups** are stateful and resource-level. Return traffic is
  automatically permitted. Reference other security groups rather than CIDRs —
  only instances with the correct SG attached can pass, not just any IP in the subnet.
- A misconfiguration in one layer does not automatically compromise the other.

---

## Visibility and Logging

- VPC Flow Logs capture metadata for every network connection across the VPC — source IP, destination IP, port, protocol, bytes, and whether the connection was accepted or rejected.
- Logs ship to two destinations. 
- CloudWatch receives them in near real time for live monitoring and alerting. 
- S3 receives them as a permanent archive that can be queried with Athena for historical forensic analysis.

Rejected traffic is logged deliberately. Blocked connection attempts reveal
port scanning, services reaching outside their intended boundaries, and early
indicators of lateral movement — often more useful than the accepted traffic.

---

## Availability

- Every tier is deployed across two availability zones — ap-south-1a and ap-south-1b. 
- If one AZ experiences an outage the other continues serving traffic independently.
- The one exception is the NAT Gateway, where this deployment uses a single instance in ap-south-1a rather than one per AZ. 
- The reasoning behind this and other deliberate tradeoffs are documented in security-decisions.md.

---