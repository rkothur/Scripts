variable "subnet_id" {
  description = "The VPC Subnet ID to launch in"
  type        = string
  default     = null
}
variable "ec2_name" {
  description = "Name to be used on EC2 instance created"
  type        = string
  default     = ""
}
variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = "t3.micro"
}
variable "iam_instance_profile" {
  description = "IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile"
  type        = string
  default     = null
}
variable "ami_id" {
  description = "ami id"
  type        = string
  default     = null
}
variable "security_group_ids" {
  description = "vpc-security-group"
  type        = list(string)
  default     = []
}
variable "tags" {
  description = "Tags"
  type        = map(string)
}