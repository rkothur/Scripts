variable "prefix" {
  description = "Prefix for resources"
  type        = string
  default     = "null"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = "null"
}

variable "emr_master_sg_name" {
  description = "EMR master security group name"
  type        = string
  default     = ""
}

variable "emr_worker_sg_name" {
  description = "EMR worker security group name"
  type        = string
  default     = ""
}

variable "emr_service_access_sg_name" {
  description = "EMR service access security group name"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
}