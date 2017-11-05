variable "name" {
  description = "Name prefix for all EFS resources."
  default     = "App"
}

variable "record" {
  description = "Record prefix for EFS endpoint."
  default     = "db"
}

variable "azs" {
  description = "A list of availability zones to associate with."
  type        = "list"
  default     = []
}

variable "access_sg_ids" {
  description = "A list of security groups Ids to grant access."
  type        = "list"
  default     = []
}

variable "vpc_id" {
  description = "VPC Id where the EFS resources will be deployed."
}

variable "newbits" {
  description = "newbits in the cidrsubnet function."
  default = 26
}

variable "netnum" {
  description = "netnum in the cidrsubnet function."
  default = 0
}

variable "rt_id" {
  description = "Route Table Id to assing to the EFS subnet."
}


variable "zone_id" {
  description = "Zone Id where the EFS record will be created."
}

variable "access_cidrs" {
  description = "A list of Subnets CIDR Blocks to grant access"
  type        = "list"
  default     = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  default     = {}
}

variable "type" {
  description = "RDS instance type."
  default     = "db.t2.small"
}

variable "db_name" {
  description = "Database name."
  default     = "app"
}

variable "db_user" {
  description = "Database user."
  default     = "app"
}

variable "db_password" {
  description = "Database password."
}
