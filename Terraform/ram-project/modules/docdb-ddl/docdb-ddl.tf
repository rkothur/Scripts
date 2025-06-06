data "aws_secretsmanager_secret" "by-arn" {
   arn = var.docdb_ddl_secrets_arn
}

data "aws_secretsmanager_secret_version" "secret-version" {
  secret_id = data.aws_secretsmanager_secret.by-arn.id
}

locals {
  example_secret = jsondecode(data.aws_secretsmanager_secret_version.secret-version.secret_string)
}

provider "mongodb" {
  host = var.docdb_ddl_host
  port = var.docdb_ddl_host_port
  username = local.example_secret["username"]
  password = local.example_secret["password"]
  auth_database = "admin"
  ssl = true
  insecure_skip_verify = true
  certificate = file(pathexpand("./global-bundle.pem"))
}

resource "mongodb_db_user" "user" {
  auth_database = "ramtestdb"
  name = "ramtest"
  password = "ramtest"
  role {
    role = "readWrite"
    db =   "ramtestdb"
  }
}