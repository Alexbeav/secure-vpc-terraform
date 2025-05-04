resource "random_id" "bucket_id" {
  count       = var.vpc_id != "" ? 1 : 0
  byte_length = 4
}

resource "aws_vpc_endpoint" "s3" {
  count             = var.vpc_id != "" && length(var.route_table_ids) > 0 ? 1 : 0
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.route_table_ids
}

data "aws_region" "current" {}
