# Roles
resource "aws_iam_group_policy" "devops" {
  name  = "devops-group-policy"
  group = "${aws_iam_group.devops.id}"

  policy     = "${data.aws_iam_policy_document.devops_group_assume.json}"
  depends_on = ["aws_iam_group.devops"]
}

resource "aws_iam_role" "devops" {
  name               = "devops-role"
  description        = "The role to be assumed by the DevOps Group"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"

  tags = {
    Description = "DevOps Role with access to related policies"
  }
}

data "aws_iam_policy_document" "devops_group_assume" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "${aws_iam_role.devops.arn}",
    ]
  }
}

resource "aws_iam_policy" "devops_base" {
  name        = "devops-base-policy"
  description = "Devops Base Policy"
  policy      = "${data.template_file.devops_base_document.rendered}"
}

resource "aws_iam_role_policy_attachment" "devops_base_attach" {
  role       = "${aws_iam_role.devops.name}"
  policy_arn = "${aws_iam_policy.devops_base.arn}"
}

data "template_file" "devops_base_document" {
  template = "${file("${path.module}/policy/devops/base.json")}"

  vars {
    account = "${local.account_id}"
    region  = "${var.region}"
    prefix  = "${var.prefix}"
  }
}

resource "aws_iam_policy" "devops_dba" {
  name        = "devops-dba-policy"
  description = "Devops DBA Policy"
  policy      = "${file("${path.module}/policy/devops/dba.json")}"
}

resource "aws_iam_role_policy_attachment" "devops_dba_attach" {
  role       = "${aws_iam_role.devops.name}"
  policy_arn = "${aws_iam_policy.devops_dba.arn}"
}

resource "aws_iam_policy" "devops_network" {
  name        = "devops-network-policy"
  description = "Devops network Policy"
  policy      = "${file("${path.module}/policy/devops/network-admin.json")}"
}

resource "aws_iam_role_policy_attachment" "devops_network_attach" {
  role       = "${aws_iam_role.devops.name}"
  policy_arn = "${aws_iam_policy.devops_network.arn}"
}

resource "aws_iam_policy" "devops_system_admin" {
  name        = "devops-system-admin-policy"
  description = "Devops System Admin Policy"
  policy      = "${file("${path.module}/policy/devops/system-admin.json")}"
}

resource "aws_iam_role_policy_attachment" "devops_system_attach" {
  role       = "${aws_iam_role.devops.name}"
  policy_arn = "${aws_iam_policy.devops_system_admin.arn}"
}
