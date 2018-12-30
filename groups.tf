resource "aws_iam_group" "admin" { #
  name = "admin"
}

resource "aws_iam_group" "devops" { #
  name = "devops"
}

resource "aws_iam_group" "iamadmin" {
  name = "iamadmin"
}

resource "aws_iam_group" "auditor" {
  name = "auditor"
}

resource "aws_iam_group" "developer" {
  name = "developer"
}

resource "aws_iam_group" "ec2admin" { #
  name = "ec2admin"
}

data "template_file" "default_policy" {
  template = "${file("${path.module}/policy/default-policy.json")}"

  vars {
    account = "${local.account_id}"
    region  = "${var.region}"
    prefix  = "${var.prefix}"
  }
}

resource "aws_iam_policy" "default_policy" {
  name        = "default-group-policy"
  description = "Policy that should be attached to every group"
  policy      = "${data.template_file.default_policy.rendered}"
}

resource "aws_iam_group_policy_attachment" "default_policy" {
  count      = "${length(local.groups)}"
  group      = "${element(local.groups, count.index)}"
  policy_arn = "${aws_iam_policy.default_policy.arn}"
}

data "aws_iam_policy_document" "defaul_mfa_policy_document" {
    statement {
        effect  = "Allow"
        actions = [
            "iam:CreateVirtualMFADevice",
        ]

        resources = [
            "arn:aws:iam::${local.account_id}:mfa/$${aws:username}",
        ]
    }

    statement {
        effect  = "Allow"
        actions = [
            "iam:EnableMFADevice",
            "iam:GetUser",
            "iam:ListGroupsForUser",
            "iam:ListVirtualMFADevices",
        ]

        resources = [
            "arn:aws:iam::${local.account_id}:user/$${aws:username}",
        ]
    }

    statement {
        effect  = "Allow"
        actions = [
            "iam:ListMFADevices",
            "iam:ListVirtualMFADevices",
            "iam:ListUsers"
        ]

        resources = [
            "arn:aws:iam::${local.account_id}:user/",
            "arn:aws:iam::${local.account_id}:mfa/",
        ]
    }

		statement {
        effect    = "Allow"
        actions   = [
            "iam:ChangePassword",
            "iam:CreateAccessKey",
            "iam:DeleteAccessKey",
            "iam:ResyncMFADevice",
            "iam:UpdateAccessKey",
            "iam:UpdateUser",
        ]

        resources = [
            "arn:aws:iam::${local.account_id}:user/$${aws:username}",
        ]
    }
}

resource "aws_iam_policy" "defaul_mfa_policy_document" {
  name        = "default-mfa-policy"
  description = "Policy to allow MFA management for itself"
  policy      = "${data.aws_iam_policy_document.defaul_mfa_policy_document.json}"
}

resource "aws_iam_group_policy_attachment" "test-attach" {
  count      = "${length(local.groups)}"
  group      = "${element(local.groups, count.index)}"
  policy_arn = "${aws_iam_policy.defaul_mfa_policy_document.arn}"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${local.account_id}:root",
      ]
    }

    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"

      values = [
        "true",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalType"

      values = [
        "User",
      ]
    }
  }
}

