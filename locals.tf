locals {
  account_id   = "${data.aws_caller_identity.current.account_id}"
  groups       = ["admin", "devops", "iamadmin", "auditor", "developer", "ec2admin"]
  environments = ["dev", "qa", "test", "prod"]
}
