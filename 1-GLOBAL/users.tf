resource "aws_iam_group" "group" {
  for_each = toset(var.iam_groups)

  name = "${var.project}-${each.key}"
  path = "/${var.project}/"
}

resource "aws_iam_user" "user" {
  for_each      = local.users
  force_destroy = false
  name          = each.key
}

/**
 * Membership of developers group
 */
resource "aws_iam_group_membership" "developers" {
  name = "${var.project}-developers-group-memberships"

  users = keys(local.users_developers)

  group = aws_iam_group.group["developers"].name

  depends_on = [
    aws_iam_user.user
  ]
}


resource "aws_iam_user_login_profile" "users_login_profile" {
  for_each = local.users

  user                     = each.key
  pgp_key                  = filebase64("./user-password-key.asc")
  password_reset_required  = true

  depends_on = [
    aws_iam_group_membership.developers,
    aws_iam_user.user,
  ]

  lifecycle {
    ignore_changes = [password_reset_required]
  }
}

locals {
  developer_attach_policies = [
    "arn:aws:iam::aws:policy/IAMUserChangePassword",
    "arn:aws:iam::aws:policy/PowerUserAccess"
  ]

  product_support_attach_policies = [
    "arn:aws:iam::aws:policy/IAMUserChangePassword",
  ]
}

resource "aws_iam_group_policy_attachment" "developer-policy-attachments" {
  count = length(local.developer_attach_policies)

  group = aws_iam_group.group["developers"].id
  policy_arn = local.developer_attach_policies[count.index]
}

resource "aws_iam_group_policy" "developers_policy_iam_AttachRolePolicy" {
  name = "${var.project}_developer_iam_AttachRolePolicy"
  group = aws_iam_group.group["developers"].id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:AttachRolePolicy",
                "iam:ChangePassword"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_group_policy" "developers_policy_AllowUserManageOwnMFA" {
  name = "${var.project}_developers_AllowUserManageOwnMFA"
  group = aws_iam_group.group["developers"].id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowUsersToCreateEnableResyncDeleteTheirOwnVirtualMFADevice",
            "Effect": "Allow",
            "Action": [
                "iam:CreateVirtualMFADevice",
                "iam:EnableMFADevice",
                "iam:ResyncMFADevice",
                "iam:DeleteVirtualMFADevice"
            ],
            "Resource": [
                "arn:aws:iam::*:mfa/$${aws:username}",
                "arn:aws:iam::*:user/$${aws:username}"
            ]
        },
        {
            "Sid": "AllowUsersToDeactivateTheirOwnVirtualMFADevice",
            "Effect": "Allow",
            "Action": [
                "iam:DeactivateMFADevice"
            ],
            "Resource": [
                "arn:aws:iam::*:mfa/$${aws:username}",
                "arn:aws:iam::*:user/$${aws:username}"
            ],
            "Condition": {
                "Bool": {
                    "aws:MultiFactorAuthPresent": true
                }
            }
        },
        {
            "Sid": "AllowUsersToListMFADevicesandUsersForConsole",
            "Effect": "Allow",
            "Action": [
                "iam:ListMFADevices",
                "iam:ListVirtualMFADevices",
                "iam:ListUsers"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_group_policy" "developers_policy_AllowUserManageOwnCredentials" {
  name = "${var.project}_developers_policy_AllowUserManageOwnCredentials"
  group = aws_iam_group.group["developers"].id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowViewAccountInfo",
            "Effect": "Allow",
            "Action": [
                "iam:GetAccountPasswordPolicy",
                "iam:GetAccountSummary"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowManageOwnPasswords",
            "Effect": "Allow",
            "Action": [
                "iam:ChangePassword",
                "iam:GetUser"
            ],
            "Resource": "arn:aws:iam::*:user/$${aws:username}"
        },
        {
            "Sid": "AllowManageOwnAccessKeys",
            "Effect": "Allow",
            "Action": [
                "iam:CreateAccessKey",
                "iam:DeleteAccessKey",
                "iam:ListAccessKeys",
                "iam:UpdateAccessKey"
            ],
            "Resource": "arn:aws:iam::*:user/$${aws:username}"
        },
        {
            "Sid": "AllowManageOwnSSHPublicKeys",
            "Effect": "Allow",
            "Action": [
                "iam:DeleteSSHPublicKey",
                "iam:GetSSHPublicKey",
                "iam:ListSSHPublicKeys",
                "iam:UpdateSSHPublicKey",
                "iam:UploadSSHPublicKey"
            ],
            "Resource": "arn:aws:iam::*:user/$${aws:username}"
        }
    ]
}
EOF
}


/**
 * Group policy for developers group
 */
resource "aws_iam_group_policy" "developers_policy" {
  name = "${var.project}_developer_policy"
  group = aws_iam_group.group["developers"].id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:PutObjectAcl",
        "s3:GetObjectAcl"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${var.project}.*/*"
      ]
    }
  ]
}
EOF
}

/**
 * Group membership of masters
 */
resource "aws_iam_group_membership" "masters" {
  name = "${var.project}-masters-group-membership"

  users = keys(local.users_admins)

  group = aws_iam_group.group["masters"].name

  depends_on = [
    aws_iam_user.user
  ]
}


/**
 * Group policy of masters
 */
resource "aws_iam_group_policy" "masters_policy" {
  name = "masters_policy"
  group = aws_iam_group.group["masters"].id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

/**
 * Instance profile for ecs instance
 */
resource "aws_iam_instance_profile" "instance_role" {
  name = "${var.project}_instance_role_profile"
  role = aws_iam_role.instance_role.name
}

/**
 * IAM role for ecs instance
 */
resource "aws_iam_role" "instance_role" {
  name = "${var.project}_instance_role"
  path = "/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
            "ec2.amazonaws.com",
            "ecs.amazonaws.com",
            "spot.amazonaws.com",
            "spotfleet.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

/**
 * Role policy for ecs instance
 */
resource "aws_iam_role_policy" "instance_role_policy" {
  name = "${var.project}_instance_role_policy"
  role = aws_iam_role.instance_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": "ecs:*",
      "Resource": "*"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:DeregisterTargets",
        "ec2:Describe*",
        "ec2:AuthorizeSecurityGroupIngress",
        "elasticache:Describe*",
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetAuthorizationToken"
      ],
      "Resource": "*"
    },
    {
      "Sid": "",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "",
      "Action": [
        "cloudfront:ListDistributions"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
