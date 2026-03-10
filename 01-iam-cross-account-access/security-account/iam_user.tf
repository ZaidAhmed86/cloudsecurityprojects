resource "aws_iam_user" "security_admin" {
    name = "SecurityAdmin"

    tags = {
        Project = "01-iam-cross-account-access"
        Environment = "security"
        ManagedBy = "terraform"
    }
}