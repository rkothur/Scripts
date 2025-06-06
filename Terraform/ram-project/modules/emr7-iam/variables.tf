variable "prefix" {
  type        = string
  default     = "null"
}
variable "emr7_release" {
  type        = string
  default     = "null"
}

variable "tags" {
  description = "Tags"
  type = map(string)
}
