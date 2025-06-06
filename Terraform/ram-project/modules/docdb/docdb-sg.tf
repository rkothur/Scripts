resource "aws_security_group" "docdb_sg" {
  name        = "${var.prefix}-${var.docdb_cluster_name}-sg"
  vpc_id      = var.vpc_id
  tags = var.tags
}

##### Security group rules
resource "aws_security_group_rule" "allow_all_out_traffic_docdb" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.docdb_sg.id
}

resource "aws_security_group_rule" "allow_inbound_internal_traffic" {
  type              = "ingress"
  from_port         = 27017
  to_port           = 27017
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/8"]
  security_group_id = aws_security_group.docdb_sg.id
}

resource "aws_security_group_rule" "self_reference_sgr" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.docdb_sg.id
}