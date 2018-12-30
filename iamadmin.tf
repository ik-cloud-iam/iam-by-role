# Roles and Groups to attach
resource "aws_iam_group_policy" "iamadmin" {
  name  = "iamadmin-group-policy"
  group = "${aws_iam_group.iamadmin.id}"

  policy = "${data.aws_iam_policy_document.iamadmin_group_assume.json}"
	depends_on = ["aws_iam_group.iamadmin"]
}

resource "aws_iam_role" "iamadmin" {
  name               = "iamadmin-role"
  description        = "The role to be assumed by the IAM Admin"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"

  tags = {
    Description = "IAM Admin with access to related policies"
  }
}

data "aws_iam_policy_document" "iamadmin_group_assume" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "${aws_iam_role.iamadmin.arn}",
    ]
  }
}

# Policies
resource "aws_iam_policy" "iamadmin" {
  name        = "iamadmin-security-policy"
  description = "IAM ADmin Security policy"
  path        = "/"
  policy      = "${file("${path.module}/policy/iamadmin/main.json")}"
}

resource "aws_iam_role_policy_attachment" "iamadmin_main" {
  role       = "${aws_iam_role.iamadmin.name}"
  policy_arn = "${aws_iam_policy.iamadmin.arn}"
}