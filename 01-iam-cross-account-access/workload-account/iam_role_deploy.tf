resource "aws_iam_role" "deployment" {
    name = "DeploymentRole"
    description = "Used by CICD pipelines to deploy to the workload account"

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
                            "sts:ExternalId" = "sec-deployment-2024"
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

# Attach Custom inline Policy for Deployment Role

resource "aws_iam_role_policy" "deployment_policy" {
    name = "DeploymentPolicy"
    role = aws_iam_role.deployment.name

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid = "S3DeployAccess"
                Effect = "Allow"
                Action = [
                    "s3:PutObject",
                    "s3:GetObject",
                    "s3:ListBucket"
                ]
                Resource = "*"
            },
            {
                Sid = "LambdaDeployAccess"
                Effect = "Allow"
                Action = [
                    "lambda:UpdateFunctionCode",
                    "Lambda:GetFunction",
                    "lambda:ListFunctions"
                ]
                Resource = "*"
            },
            {
                Sid = "ECRDeployAccess"
                Effect = "Allow"
                Action = [
                    "ecr:GetDownloadUrlForLayer",
                    "ecr:BatchGetImage",
                    "ecr:PutImage"
                ]
                Resource = "*"
            }
        ]
    })
}