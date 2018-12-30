provider "aws" {
  region = "${var.region}"

	 version = ">= 1.41.0"
}

provider "template" {}