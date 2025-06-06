resource "aws_docdb_cluster_parameter_group" "docdb_parameter_group" {
   family = "docdb4.0"
   name   = "${var.prefix}-${var.docdb_cluster_name}-parameter-group"
   parameter {
     name = "tls"
     value = "enabled"
   }

  tags = var.tags
}