### VPC ###
variable "nginx_vpc" {
  description = "Testing VPC"
  type        = string
  default     = "10.0.0.0/16"
}

### EC2 COMPONENTS###
variable "instance_tenancy" {
  description = "Defines tenancy of the VPC - dedicated or default"
  type        = string
  default     = "default"
}

variable "ami_id" {
  description = "ami id"
  type        = string
  default     = "ami-0ff35fbb0a77fa5c5"
}

variable "instance_type" {
  description = "Type of instance used during provisioning"
  type        = string
  default     = "t2.micro"
}

### SSH KEYS ###
variable "PRIVATE_KEY_PATH" {
  default = "/Users/nick.bratton/ssh_key_pair"
}

variable "PUBLIC_KEY_PATH" {
  default = "/Users/nick.bratton/ssh_key_pair.pub"
}