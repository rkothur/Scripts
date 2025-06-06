# Terraform for Creating DocumentDB users, roles and databases

1. Deploy the Document DB terraform code 
2. Update the platform-<env>.tfvars file
    a. docdb_ddl_host                   = "ramtest-dev-ramtest-docdb.cluster-cxceemwk6023.us-east-1.docdb.amazonaws.com"
    b. docdb_ddl_host_port              = "27017"
    c. docdb_ddl_secrets_arn            = "arn:aws:secretsmanager:us-east-1:677276120473:secret:docdb.ramtest-dev-ramtest-docdb-lCPMiZ"
3. Deploy the code in gitlab
