data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "wireguard_policy_doc" {
  statement {
    actions = [
      "ec2:AssociateAddress",
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "wireguard_policy" {
  name        = "${var.project}-${var.environment}-tf-wireguard"
  description = "Terraform Managed. Allows Wireguard instance to attach EIP."
  policy      = data.aws_iam_policy_document.wireguard_policy_doc.json
}

resource "aws_iam_role" "wireguard_role" {
  name               = "${var.project}-${var.environment}-tf-wireguard"
  description        = "Terraform Managed. Role to allow Wireguard instance to attach EIP."
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy_attachment" "wireguard_roleattach" {
  role       = aws_iam_role.wireguard_role.name
  policy_arn = aws_iam_policy.wireguard_policy.arn
}

resource "aws_iam_instance_profile" "wireguard_profile" {
  name = "${var.project}-${var.environment}-tf-wireguard"
  role = aws_iam_role.wireguard_role.name
}
