# DocumentDB Terraform deployment

1. Update the platform-<env>.tfvars file 
    a. docdb_version                    = "4.0.0"
    b. docdb_no_of_nodes                = "3"
    c. docdb_instance_class             = "db.t3.medium"
    d. docdb_backup_window              = "07:00-09:00"
2. Deploy the code using gitlab
