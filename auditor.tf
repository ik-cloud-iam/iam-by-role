# Roles
resource "aws_iam_group_policy" "auditor" {
  name  = "auditor-group-policy"
  group = "${aws_iam_group.auditor.id}"

  policy     = "${data.aws_iam_policy_document.auditor_group_assume.json}"
  depends_on = ["aws_iam_group.auditor"]
}

resource "aws_iam_role" "auditor" {
  name               = "auditor-role"
  description        = "The role to be assumed by the Auditor Group"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"

  tags = {
    Description = "Auditor Role with access to related policies"
  }
}

data "aws_iam_policy_document" "auditor_group_assume" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "${aws_iam_role.auditor.arn}",
    ]
  }
}

# Policies
resource "aws_iam_policy" "auditor_security" {
  name        = "auditor-security-policy"
  description = "Auditor Security policy"
  path        = "/"
  policy      = "${file("${path.module}/policy/auditor/main.json")}"
}

resource "aws_iam_role_policy_attachment" "auditor_security" {
  role       = "${aws_iam_role.auditor.name}"
  policy_arn = "${aws_iam_policy.auditor_security.arn}"
}

resource "aws_iam_policy" "auditor_viewonly" {
  name        = "auditor-viewonly-policy"
  description = "Auditor Viewonly policy"
  path        = "/"
  policy      = "${file("${path.module}/policy/auditor/viewonly.json")}"
}

resource "aws_iam_role_policy_attachment" "auditor_viewonly" {
  role       = "${aws_iam_role.auditor.name}"
  policy_arn = "${aws_iam_policy.auditor_viewonly.arn}"
}
