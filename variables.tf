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
  default     = "t3.medium"
  type        = string
}

variable "ssh_user" {
  description = "The default username for the AMI"
  type        = string
  default     = "centos"
}

variable "ssh_key" {
  description = "Key name to use"
  default     = "mminichino-default-key-pair"
  type        = string
}

variable "ssh_private_key" {
  description = "The private key to use when connecting to the instances"
  default     = "/home/admin/.ssh/mminichino-default-key-pair.pem"
  type        = string
}

variable "subnet_id" {
  description = "Subnet to launch the instances in"
  default     = "subnet-04a39c94478a470bc"
  type        = string
}

variable "vpc_id" {
  description = "VPC Id"
  default     = "vpc-02140d5eb28cbe7f3"
  type        = string
}

variable "security_group_ids" {
  description = "Security group to assign to the instances"
  default     = ["sg-0461893dc9f5472d1"]
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
  default     = "gp3"
  type        = string
}
