# 01-public-private-nat/provider.tf
provider "aws" {
  region  = "eu-west-1"
  profile = "crosstalkis-admin"
}
