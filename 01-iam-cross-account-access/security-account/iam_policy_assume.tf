resource "aws_iam_policy" "assume_roles_workload" {
    name = "AssumeRoleInWorkloadAccount"
    description = "Allows security admin to assume roles in the workload account"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
            Effect = "Allow"
            Action = "sts:AssumeRole"
            Resource = [
                "arn:aws:iam::117327730775:role/SecurityAuditRole",
                "arn:aws:iam::117327730775:role/IncidentResonseRole",
                "arn:aws:iam::117327730775:role/DeploymentRole"
            ]
            }
        ]
    })

    tags = { 
        Project = "01-iam-cross-account-access"
        ManagedBy = "terraform"
    }
}

resource "aws_iam_user_policy_attachment" "attach_assume_roles" {
    user = aws_iam_user.security_admin.name
    policy_arn = aws_iam_policy.assume_roles_workload.arn
}