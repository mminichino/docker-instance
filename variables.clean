##########################################################
#
# Default values for creating a Couchbase cluster on AWS.
#
##########################################################

variable "region_name" {
  description = "Region name"
  default     = "us-east-2"
  type        = string
}

variable "instance_type" {
  description = "Instance type"
  default     = "c4.xlarge"
  type        = string
}

variable "ssh_user" {
  description = "The default username for the AMI"
  type        = string
  default     = "centos"
}

variable "ssh_key" {
  description = "Key name to use"
  default     = ""
  type        = string
}

variable "ssh_private_key" {
  description = "The private key to use when connecting to the instances"
  default     = ""
  type        = string
}

variable "subnet_id" {
  description = "Subnet to launch the instances in"
  default     = ""
  type        = string
}

variable "vpc_id" {
  description = "VPC Id"
  default     = ""
  type        = string
}

variable "security_group_ids" {
  description = "Security group to assign to the instances"
  default     = [""]
  type        = list(string)
}

variable "root_volume_iops" {
  description = "IOPS (only for io1 volume type)"
  default     = "0"
  type        = string
}

variable "root_volume_size" {
  description = "The root volume size"
  default     = "50"
  type        = string
}

variable "root_volume_type" {
  description = "The root volume type"
  default     = "gp2"
  type        = string
}
