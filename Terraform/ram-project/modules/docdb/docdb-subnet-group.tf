resource "aws_docdb_subnet_group" "docdb_subnet_group" {
  name       = "${var.prefix}-${var.docdb_cluster_name}-subnet-group"
  subnet_ids = var.priv_subnets

  tags = var.tags
}