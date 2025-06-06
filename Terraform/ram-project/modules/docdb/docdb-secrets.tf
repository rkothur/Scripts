resource "random_password" "pass" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}


 variable "secrets" {
  default = {}
  type = map(string)
}

locals {
  secret_contents = merge(
    var.secrets,
    {
      password = random_password.pass.result
      username = var.docdb_master_username
    }
  )
}

resource "aws_secretsmanager_secret" "db" {
name = format("%s.%s" , "docdb" , "${aws_docdb_cluster.docdb_cluster.id}")
description = format("%s.%s" , "Secret associated with primary DocumentDB instance=", "${aws_docdb_cluster.docdb_cluster.arn}")
tags = var.tags
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id     = aws_secretsmanager_secret.db.id
  secret_string = jsonencode(local.secret_contents)
}
