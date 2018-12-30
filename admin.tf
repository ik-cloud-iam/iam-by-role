# Roles and Groups
resource "aws_iam_group_policy" "admin" {
  name  = "admin-group-policy"
  group = "${aws_iam_group.admin.id}"

  policy     = "${data.aws_iam_policy_document.admin_group_assume.json}"
  depends_on = ["aws_iam_group.admin"]
}

resource "aws_iam_role" "admin" {
  name               = "admin-role"
  description        = "The role to be assumed by the Administator Group"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"

  tags = {
    Description = "Administator Role with access to related policies"
  }
}

data "aws_iam_policy_document" "admin_group_assume" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "${aws_iam_role.admin.arn}",
    ]
  }
}

# Policies
resource "aws_iam_policy" "admin_base" {
  name        = "admin-base-policy"
  description = "Admin Base Policy"
  policy      = "${file("${path.module}/policy/admin/main.json")}"
}

resource "aws_iam_role_policy_attachment" "admin_base_attach" {
  role       = "${aws_iam_role.admin.name}"
  policy_arn = "${aws_iam_policy.admin_base.arn}"
}
