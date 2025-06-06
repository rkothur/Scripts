 variable "account_name" {
   type        = string
   default     = null
 }

 variable "account_no" {
   type        = string
   default     = null
 }

 variable "prefix" {
   type        = string
   default     = null
 }

 variable "aws_region" {
   type        = string
   default     = null
 }

 variable "vpc_id" {
   type        = string
   default     = null
 }

 variable "vpc_cidr" {
   type        = string
   default     = null
 }

 variable "emr7_subnet_id" {
   type        = string
   default     = null
 }

 variable "emr7_Inst_Id" {
   type        = string
   default     = null
 }

 variable "emr7_ip" {
   type        = string
   default     = null
 }

 variable "emr7_instance_type" {
   type        = string
   default     = null
 }

 variable "emr7_instance_count" {
   type        = number
   default     = null
 }

 variable "emr7_admin_key_name" {
   type        = string
   default     = null
 }

 variable "emr7_vpc_security_group" {
   type        = string
   default     = null
 }

 variable "emr7_iam_instance_profile" {
   type        = string
   default     = null
 }

 variable "emr7_app_user_keyname" {
   type        = string
   default     = null
 }

 variable "emr7_tagent_name" {
   type        = string
   default     = null
 }

 variable "emr7_tagent_minmem" {
   type        = number
   default     = null
 }

 variable "emr7_tagent_maxmem" {
   type        = number
   default     = null
 }

 variable "tags" {
  type = map(string)
  default = null
}