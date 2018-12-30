# Roles and Groups to attach
resource "aws_iam_group_policy" "ec2admin" {
  name  = "ec2admin-group-policy"
  group = "${aws_iam_group.ec2admin.id}"

  policy = "${data.aws_iam_policy_document.ec2admin_group_assume.json}"
}

resource "aws_iam_role" "ec2admin" {
  name               = "ec2admin-role"
  description        = "The role to be assumed by the EC2 Admin"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"

  tags = {
    Description = "EC2 Admin with access to related policies"
  }
}

data "aws_iam_policy_document" "ec2admin_group_assume" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "${aws_iam_role.ec2admin.arn}",
    ]
  }
}

# Policies
data "template_file" "ec2main" {
  template = "${file("${path.module}/policy/ec2admin/main.json")}"

  vars = {
    region = "${var.region}"
  }
}

resource "aws_iam_policy" "ec2main" {
  name        = "ec2main-policy"
  description = "EC2 main policy"
  path        = "/"
  policy      = "${data.template_file.ec2main.rendered}"
}
