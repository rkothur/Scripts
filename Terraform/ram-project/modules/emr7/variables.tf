variable "prefix" {
  type = string
  default = null
}

variable "tags" {
  description = "Tags"
  type = map(string)
}

variable "priv_subnets" {
  type = list(string)
  default = null
}

variable "emr7_app_user_keyname" {
  type = string
  default = null
}

variable "emr7_release" {
  type = string
  default = null
}

variable "emr7_master_node_count" {
  type = number  
  default = null
}

variable "emr7_core_node_count" {
  type = number
  default = null
}

variable "emr7_task_node_min_count" {
  type = number
  default = null
}

variable "emr7_task_ondemand_node_count" {
  type = number
  default = null
}

variable "emr7_task_node_max_count" {
  type = number
  default = null
}

variable "emr7_master_instance_type" {
  type = string
  default = null
}

variable "emr7_hadoop_configurations_json" {
  type = string
  default = null
}

variable "emr7_instance_profile" {
  type = string
  default = null
}

variable "emr7_key_name" {
  type = string
  default = null
}

variable "emr7_ebs_size" {
  type = number
  default = null
}

variable "emr7_ebs_type" {
  type = string
  default = null
}

variable "emr7_root_volume_size" {
  type = number
  default = null
}

variable "emr7_ebs_disk_count" {
  type = number
  default = null
}

variable "emr7_applications" {
  type = list(string)
  default = null
}
variable "emr7_service_access_sg" {
   type        = string
   default     = null
}

variable "emr7_worker_sg" {
   type        = string
   default     = null
}

variable "emr7_master_sg" {
   type        = string
   default     = null
}
variable "emr7_EMRClusterServiceRole" {
  type = string
  default = null
}
variable "emr7_EMRClusterServiceRole_arn" {
  type = string
  default = null
}
variable "emr7_EMRClusterInstanceProfileRole" {
  type = string
  default = null
}
variable "emr7_core_instance_type1" {
   type        = string
   default     = null
}
variable "emr7_core_instance_type2" {
   type        = string
   default     = null
}
variable "emr7_core_instance_type3" {
   type        = string
   default     = null
}
variable "emr7_task_instance_type1" {
   type        = string
   default     = null
}
variable "emr7_task_instance_type2" {
   type        = string
   default     = null
}
variable "emr7_task_instance_type3" {
   type        = string
   default     = null
}
