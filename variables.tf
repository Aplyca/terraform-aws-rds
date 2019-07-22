variable "name" {
  description = "Name prefix for all EFS resources."
  default     = "App"
}

variable "cluster" {
  description = "Enable/disable cluster."
  default     = false
}

variable "storage" {
  description = "Storage size for the DB."
  default     = 10
}

variable "port" {
  description = "DB port."
  default     = 3306
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

variable "engine" {
  description = "Engine"
  default     = "aurora-mysql"
}

variable "engine_version" {
  description = "Engine version"
  default     = "5.7"
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

variable "db_snapshot_identifier" {
  description = "Snapshot for creating new DB."
  default = ""
}
