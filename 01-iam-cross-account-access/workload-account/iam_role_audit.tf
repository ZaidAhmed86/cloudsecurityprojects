resource "aws_iam_role" "security_audit" {
    name = "SecurityAuditRole"
    description = "Read only role for security reviews from the security account"

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
                        "sts:ExternalId" = "sec-audit-2024"
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

resource "aws_iam_role_policy_attachment" "security_audit_policy" {
    role = aws_iam_role.security_audit.name
    policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

resource "aws_iam_role_policy_attachment" "view_only_policy" {
    role = aws_iam_role.security_audit.name
    policy_arn = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
}
