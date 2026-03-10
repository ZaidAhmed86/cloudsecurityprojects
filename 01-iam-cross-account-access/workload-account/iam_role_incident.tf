resource "aws_iam_role" "incident_response_role" {
    name = "IncidentResponseRole"
    description = "Limited write access for handling active incidents from the security account"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    AWS = "arn:aws:iam::621715857254:root"
                }
                Action = "sts:AssumeRole"
                Condition = {
                    StringEquals = {
                        "sts:Externalid" = "sec-incident-2024"
                    }
                    Bool = {
                        "aws:MultiFactorAuthPresent" = "true"
                    }
                }
            }
        ]
    })

    tags = {
        Project = "01-iam-cross-account-access"
        Environment = "workload"
        ManagedBy = "terraform"
    }
}

# Incident Response Role Limited Write Access Policy Attachment

resource "aws_iam_role_policy" "incident_response_policy" {
    name = "IncidentResponsePolicy"
    role = aws_iam_role.incident_response_role.name

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid = "ReadOnlyAccess"
                Effect = "Allow"
                Action = [
                    "ec2:Describe*",
                    "vpc:Describe*",
                    "iam:Get*",
                    "iam:List*",
                    "cloudtrail:LookupEvents",
                    "cloudtrail:GetEventStatus"
                ]
                Resource = "*"
            },
            {
                Sid = "LimitedWriteAccess"
                Effect = "Allow"
                Action = [
                    "ec2:StopInstance",
                    "ec2:RevokeSecurityGroupIngress",
                    "ec2:RevokeSecurityGroupEgress"
                ]
                Resource = "*"
            }
        ]
    })
}