
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

variable "mwaa_priv_subnets" {
  type = list(string)
  default = null
}

variable "tags" {
  description = "Tags"
  type = map(string)
}

variable "aws_region" {
  description = "AWS Region"
  type = string
}

variable "mwaa_name" {
  description = "mwaa_name"
  type = string
}

variable "mwaa_version" {
  description = "mwaa version"
  type = string
}

variable "mwaa_node_type" {
  description = "mwaa_node_type"
  type = string
}

variable "mwaa_min_workers" {
  description = "mwaa_min_workers"
  type = string
}

variable "mwaa_max_workers" {
  description = "mwaa_max_workers"
  type = string
}

variable "mwaa_webserver_access_mode" {
  description = "mwaa_webserver_access_mode"
  type = string
}

variable "mwaa_s3_bucket_arn" {
  description = "mwaa_s3_bucket_arn"
  type   = string
  default = null
}

variable "mwaa_dag_s3_path" {
  description = "mwaa_dag_s3_path"
  type = string
}

variable "mwaa_plugins_s3_path" {
  description = "mwaa_plugins_s3_path"
  type = string
}

variable "mwaa_requirements_s3_path" {
  description = "mwaa_requirements_s3_path"
  type = string
}

variable "mwaa_maintenance_window" {
  description = "mwaa_maintenance_window"
  type = string
}

variable "mwaa_dag_processing_logs_enabled" {
  description = "mwaa_dag_processing_logs_enabled"
  type = string
}

variable "mwaa_dag_processing_logs_level" {
  description = "mwaa_dag_processing_logs_level"
  type = string
}

variable "mwaa_scheduler_logs_enabled" {
  description = "mwaa_scheduler_logs_enabled"
  type = string
}

variable "mwaa_scheduler_logs_level" {
  description = "mwaa_scheduler_logs_level"
  type = string
}

variable "mwaa_task_logs_enabled" {
  description = "mwaa_task_logs_enabled"
  type = string
}

variable "mwaa_task_logs_level" {
  description = "mwaa_task_logs_level"
  type = string
}

variable "mwaa_webserver_logs_enabled" {
  description = "mwaa_webserver_logs_enabled"
  type = string
}

variable "mwaa_webserver_logs_level" {
  description = "mwaa_webserver_logs_level"
  type = string
}

variable "mwaa_worker_logs_enabled" {
  description = "mwaa_worker_logs_enabled"
  type = string
}

variable "mwaa_worker_logs_level" {
  description = "mwaa_worker_logs_level"
  type = string
}
