# 01-public-private-nat/provider.tf
provider "aws" {
  region = var.aws_region
}
