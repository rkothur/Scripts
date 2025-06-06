/* Create EMR Service Access Security Group */
resource "aws_security_group" "service_access_sg" {
    revoke_rules_on_delete = true
    vpc_id = var.vpc_id
    //name = "emr-service-access-sg"
    name = "${var.prefix}-${var.emr_service_access_sg_name}"
    description = "EMR ServiceAcess Security Group"
    tags = var.tags
}
#comment for testingedit option
/* Create Master Security Group */
resource "aws_security_group" "master_sg" {
    revoke_rules_on_delete = true
    vpc_id = var.vpc_id
    //name = "emr-master-sg"
    name = "${var.prefix}-${var.emr_master_sg_name}"
    description = "EMR Managed Master Security Group"
    tags = var.tags
}

/* Create Worker Security Group */
    resource "aws_security_group" "worker_sg" {
    revoke_rules_on_delete = true
    vpc_id = var.vpc_id
    //name = "emr-worker-sg"
    name = "${var.prefix}-${var.emr_worker_sg_name}"
    description = "EMR Managed Worker Security Group"
    tags = var.tags
}

/* Inbound and out bound Rule to Master Security Group */
resource "aws_security_group_rule" "master_udp_1"{
    type = "ingress"
    from_port = 0
    to_port = 65535
    protocol = "udp"
    security_group_id = aws_security_group.master_sg.id
    source_security_group_id = aws_security_group.master_sg.id
}
resource "aws_security_group_rule" "master_udp_2"{
    type = "ingress"
    from_port = 0
    to_port = 65535
    protocol = "udp"
    security_group_id = aws_security_group.master_sg.id
    source_security_group_id = aws_security_group.worker_sg.id
}
resource "aws_security_group_rule" "master_icmp_1"{
    type = "ingress"
    from_port = -1
    to_port = -1
    protocol = "icmp"
    security_group_id = aws_security_group.master_sg.id
    source_security_group_id = aws_security_group.master_sg.id
}
resource "aws_security_group_rule" "master_icmp_2"{
    type = "ingress"
    from_port = -1
    to_port = -1
    protocol = "icmp"
    security_group_id = aws_security_group.master_sg.id
    source_security_group_id = aws_security_group.worker_sg.id
}
resource "aws_security_group_rule" "master_tcp_8443" {
    type = "ingress"
    from_port = 8443
    to_port = 8443
    protocol = "tcp"
    security_group_id = aws_security_group.master_sg.id
    source_security_group_id = aws_security_group.service_access_sg.id
}
resource "aws_security_group_rule" "master_tcp_1" {
    type = "ingress"
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    security_group_id = aws_security_group.master_sg.id
    source_security_group_id = aws_security_group.master_sg.id
}
resource "aws_security_group_rule" "master_tcp_2" {
    type = "ingress"
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    security_group_id = aws_security_group.master_sg.id
    source_security_group_id = aws_security_group.worker_sg.id
}
resource "aws_security_group_rule" "master_ipv_1"{
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    ipv6_cidr_blocks = ["::/0"]
    security_group_id = aws_security_group.master_sg.id
}
resource "aws_security_group_rule" "master_cidr_1"{
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.master_sg.id
}
resource "aws_security_group_rule" "master_cidr_site_twc"{
    type = "ingress"
    from_port = 0
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    security_group_id = aws_security_group.master_sg.id
}

/* Inbound and out bound Rule to Worker Security Group */
resource "aws_security_group_rule" "worker_udp_1"{
    type = "ingress"
    from_port = 0
    to_port = 65535
    protocol = "udp"
    security_group_id = aws_security_group.worker_sg.id
    source_security_group_id = aws_security_group.master_sg.id
}
resource "aws_security_group_rule" "worker_udp_2"{
    type = "ingress"
    from_port = 0
    to_port = 65535
    protocol = "udp"
    security_group_id = aws_security_group.worker_sg.id
    source_security_group_id = aws_security_group.worker_sg.id
}
resource "aws_security_group_rule" "worker_icmp_1"{
    type = "ingress"
    from_port = -1
    to_port = -1
    protocol = "icmp"
    security_group_id = aws_security_group.worker_sg.id
    source_security_group_id = aws_security_group.master_sg.id
}
resource "aws_security_group_rule" "worker_icmp_2"{
    type = "ingress"
    from_port = -1
    to_port = -1
    protocol = "icmp"
    security_group_id = aws_security_group.worker_sg.id
    source_security_group_id = aws_security_group.worker_sg.id
}
resource "aws_security_group_rule" "worker_tcp_8443" {
    type = "ingress"
    from_port = 8443
    to_port = 8443
    protocol = "tcp"
    security_group_id = aws_security_group.worker_sg.id
    source_security_group_id = aws_security_group.service_access_sg.id
}
resource "aws_security_group_rule" "worker_tcp_1" {
    type = "ingress"
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    security_group_id = aws_security_group.worker_sg.id
    source_security_group_id = aws_security_group.master_sg.id
}
resource "aws_security_group_rule" "worker_tcp_2" {
    type = "ingress"
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    security_group_id = aws_security_group.worker_sg.id
    source_security_group_id = aws_security_group.worker_sg.id
}
resource "aws_security_group_rule" "worker_ipv_outbound"{
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    ipv6_cidr_blocks = ["::/0"]
    security_group_id = aws_security_group.worker_sg.id
}
resource "aws_security_group_rule" "worker_cidr_outbound"{
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.worker_sg.id
}

/* Inbound and out bound Rule to service_access Security Group */
resource "aws_security_group_rule" "service_access_tcp_8443" {
    type = "ingress"
    from_port = 9443
    to_port = 9443
    protocol = "tcp"
    //cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.service_access_sg.id
    source_security_group_id = aws_security_group.master_sg.id
}
resource "aws_security_group_rule" "service_access_ipv_outbound"{
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    ipv6_cidr_blocks = ["::/0"]
    security_group_id = aws_security_group.service_access_sg.id
}
resource "aws_security_group_rule" "serviceaccess_tcp_outbound"{
    type = "egress"
    from_port = 8443
    to_port = 8443
    protocol = "tcp"
    security_group_id = aws_security_group.service_access_sg.id
    source_security_group_id = aws_security_group.worker_sg.id
}
resource "aws_security_group_rule" "serviceaccess_tcp_out"{
    type = "egress"
    from_port = 8443
    to_port = 8443
    protocol = "tcp"
    security_group_id = aws_security_group.service_access_sg.id
    source_security_group_id = aws_security_group.master_sg.id
}

