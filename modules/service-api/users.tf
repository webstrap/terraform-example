resource "aws_iam_user" "deployer" {
  name = "${var.project}-${var.environment}-ecs-deployer-${var.service_name}"
  path = "/${var.project}-${var.environment}-deployers/"
}

resource "aws_iam_access_key" "deployer" {
  user = aws_iam_user.deployer.name
}

resource "aws_iam_user_policy" "deployer-policy" {
  name = "${var.project}-${var.environment}-ecs-deployer-${var.service_name}-policy"
  user = aws_iam_user.deployer.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ecsGlobalDescribe",
      "Action": [
        "ecs:DescribeServices",
        "ecs:UpdateService",
        "ecs:DescribeTaskDefinition",
        "ecs:RegisterTaskDefinition"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "ecrGlobalUpdate",
      "Action": [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:GetAuthorizationToken",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
