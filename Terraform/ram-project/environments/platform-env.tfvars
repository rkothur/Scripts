########## MWAA Parameters ##########
###### General #####

tags = {
   email         = "dl-corp-it-bigdata-admins@charter.com"
   app           = "smdh-test" 
   app_id        = "APP2560" 
   cost_code     = "3047100821" 
   team          = "dp-sdh-pe" 
   data_priv     = "Internal"
   group         = "sdh" 
   vp            = "Nate Vogel" 
   org           = "data-platforms" 
   ops_owner     = "Mani Kalyan" 
   sec_owner     = "Mani Kalyan" 
   dev_owner     = "Mani kalyan" 
   app_ref_id    = "mtDDh"
   solution      = "smdh"
}

###### Account Details ######
account_name     = "SpectrumMobileDataHub-SDIT-dev"
account_no       = "677276120473"
prefix           = "ramtest-dev"

###### Networking #####
vpc_id           = "vpc-0adbe412686f9b677"
aws_region       = "us-east-1"
priv_subnets     = ["subnet-078a70720edf3cc78","subnet-0215e7f0dbe5bbd85","subnet-050cc826f7acd693e","subnet-029cf120d92004e55"]
pub_subnets      = ["subnet-0a758094df55a37cb","subnet-0a689525eea3627d0","subnet-06e124acb0f41dd78","subnet-009c7c9d54414ab58"]
local_subnets    = ["subnet-04af849c6aa14691f","subnet-0143d194f38f02746","subnet-0ef56567cce3971c8","subnet-0820e2ed69a04e647"]

###### MWAA - S3 #####
mwaa_s3_bucket_name       = "mwaa-s3"
mwaa_s3_archive_days      = "90"
mwaa_s3_deep_archive_days = "180" 

###### MWAA #####
mwaa_name                        = "mwaa"
mwaa_version                     = "2.9.2"
mwaa_node_type                   = "mw1.small"
mwaa_min_workers                 = "1"
mwaa_max_workers                 = "3"
mwaa_s3_bucket_arn               = "arn:aws:s3:::ramtest-dev-mwaa-s3"
mwaa_dag_s3_path                 = "dags"
mwaa_webserver_access_mode       = "PRIVATE_ONLY"
mwaa_plugins_s3_path             = "plugins.zip"
mwaa_requirements_s3_path        = "requirements.txt"
mwaa_maintenance_window          = "SUN:19:00"
mwaa_dag_processing_logs_enabled = true
mwaa_dag_processing_logs_level   = "WARNING" 
mwaa_scheduler_logs_enabled      = true
mwaa_scheduler_logs_level        = "WARNING"
mwaa_task_logs_enabled           = true
mwaa_task_logs_level             = "WARNING"
mwaa_webserver_logs_enabled      = true
mwaa_webserver_logs_level        = "WARNING"
mwaa_worker_logs_enabled         = true
mwaa_worker_logs_level           = "WARNING"
mwaa_priv_subnets                = ["subnet-078a70720edf3cc78","subnet-0215e7f0dbe5bbd85"]


########## DocumentDB ##########
docdb_cluster_name               = "docdb"
docdb_version                    = "4.0.0"
docdb_no_of_nodes                = "3"
docdb_avaiability_zones          = ["us-east-1a","us-east-1b","us-east-1c"]
//docdb_avaiability_zone         = "us-east-1a"
docdb_instance_class             = "db.t3.medium"
docdb_master_username            = "svcbdadmin"
//docdb_master_password          = "encrypted"
docdb_backup_retention_days      = "5"
docdb_backup_window              = "07:00-09:00"
docdb_skip_final_snapshot        = "true"
docdb_apply_immediately          = "false"
docdb_auto_minor_version_upgrade = "false"
docdb_copy_tags_to_snapshot      = "true" 
docdb_storage_encrypted          = "true"
docdb_deletion_protection        = "true"

########## DocumentDB - DDL ##########
docdb_ddl_wget_loc               = "https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem"
docdb_ddl_host                   = "ramtest-dev-ramtest-docdb.cluster-cxceemwk6023.us-east-1.docdb.amazonaws.com"
docdb_ddl_host_port              = "27017"
docdb_ddl_secrets_arn            = "arn:aws:secretsmanager:us-east-1:677276120473:secret:docdb.ramtest-dev-ramtest-docdb-lCPMiZ"