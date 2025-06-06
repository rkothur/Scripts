
resource "aws_docdb_cluster_instance" "docdb_cluster_instance" {
    count              = var.docdb_no_of_nodes
    identifier         = "${var.prefix}-${var.docdb_cluster_name}-${count.index}"
    instance_class     = var.docdb_instance_class
    tags               = var.tags
    cluster_identifier = aws_docdb_cluster.docdb_cluster.id
}

resource "aws_docdb_cluster" "docdb_cluster" {
    cluster_identifier              = "${var.prefix}-${var.docdb_cluster_name}"
    engine                          = "docdb"
    master_username                 = var.docdb_master_username
    vpc_security_group_ids          = [aws_security_group.docdb_sg.id] 
    //master_password               = var.docdb_master_password
    master_password                 = random_password.pass.result
    //apply_immediately             = var.docdb_apply_immediately - Error: DocumentDB Cluster FinalSnapshotIdentifier is required when a final snapshot is required - manually changed skip_final_snapshot to true in terraform.tfstate file
    apply_immediately               = true
    //backup_retention_period       = var.docdb_backup_retention_days -Error: DocumentDB Cluster FinalSnapshotIdentifier is required when a final snapshot is required
    backup_retention_period         = 0
    preferred_backup_window         = var.docdb_backup_window
    storage_encrypted               = var.docdb_storage_encrypted
    db_subnet_group_name            = aws_docdb_subnet_group.docdb_subnet_group.name
    db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.docdb_parameter_group.name
    engine_version                  = var.docdb_version
    //skip_final_snapshot = var.docdb_skip_final_snapshot - Error: DocumentDB Cluster FinalSnapshotIdentifier is required when a final snapshot is required
    skip_final_snapshot             = true
    deletion_protection             = var.docdb_deletion_protection
    availability_zones              = var.docdb_avaiability_zones
    final_snapshot_identifier       = "${var.prefix}-${var.docdb_cluster_name}-final-snapshot"
    tags                            = var.tags
}