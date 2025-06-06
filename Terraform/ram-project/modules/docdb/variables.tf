
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

variable "docdb_no_of_nodes" {
  description = "docdb_no_of_nodes"
  type = string
}

variable "docdb_instance_class" {
  description = "docdb_instance_class"
  type = string
}

variable "docdb_cluster_name" {
  description = "docdb_cluster_name"
  type = string
}

variable "docdb_avaiability_zones" {
  description = "docdb_avaiability_zones"
  type = list(string)
}

variable "docdb_version" {
  description = "docdb_version"
  type = string
}

variable "docdb_master_username" {
  description = "docdb_master_username"
  type = string
}

variable "docdb_master_password" {
  description = "docdb_master_password"
  type   = string
  default = null
}

variable "docdb_apply_immediately" {
  description = "docdb_apply_immediately"
  type = string
}

variable "docdb_backup_retention_days" {
  description = "docdb_backup_retention_days"
  type = string
}

variable "docdb_backup_window" {
  description = "docdb_backup_window"
  type = string
}

variable "docdb_storage_encrypted" {
  description = "docdb_storage_encrypted"
  type = string
}

variable "docdb_skip_final_snapshot" {
  description = "docdb_skip_final_snapshot"
  type = string
}

variable "docdb_deletion_protection" {
  description = "docdb_deletion_protection"
  type = string
}
