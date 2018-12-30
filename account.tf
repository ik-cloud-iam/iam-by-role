resource "aws_iam_account_password_policy" "password_policy" {
  minimum_password_length        = 30
  password_reuse_prevention      = 5
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
	hard_expiry                    = true
}
