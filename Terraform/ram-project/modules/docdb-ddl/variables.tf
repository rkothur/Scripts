
variable "prefix" {
  type = string
  default = null
}

variable "account_no" {
  type = string
  default = null
}

variable "vpc_id" {
  type = string
  default = null
}

variable "priv_subnets" {
  type = list(string)
  default = null
}

variable "tags" {
  description = "Tags"
  type = map(string)
}

variable "docdb_ddl_wget_loc" {
  description = "docdb_ddl_wget_loc"
  type = string
}

variable "docdb_ddl_host" {
  description = "docdb_ddl_host"
  type = string
}

variable "docdb_ddl_host_port" {
  description = "docdb_ddl_host_port"
  type = string
}

variable "docdb_ddl_secrets_arn" {
  description = "docdb_ddl_secrets_arn"
  type = string
}