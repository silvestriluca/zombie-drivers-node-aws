####### GENERAL VARIABLES #######
variable "app_name_verbose" {
  type        = string
  description = "Name of the app/service. Verbose version"
  default     = "zombie-drivers"
}

variable "app_name_prefix" {
  type        = string
  description = "Name of the app/service. Prefix (short) version"
  default     = "zdriv"
}

variable "app_repository_name" {
  type        = string
  description = "Name of the repositoy where the IaC and/or app/service code is stored"
  default = "github/zombie-drivers-node-aws"
}

variable "aws_region" {
  type        = string
  description = "Name of the region where resources will be deployed"
  default     = "eu-west-1"
}

variable "environment" {
  type        = string
  description = "Name of the environment in which the app/service will be deployed (e.g. network, lab, application, DMZ)"
  default     = "application/microservices"
}

variable "stage" {
  type        = string
  description = "Name of the stage in which the app/service will be deployed (e.g. dev, int, prod, test, ephemeral, canary, RC, seed)"
  default     = "dev"
}

####### VPC VARIABLES #######
variable "az1" {
  description = "Availability Zone 1"
  type        = string
  default     = "eu-west-1a"
}
variable "az2" {
  description = "Availability Zone 2"
  type        = string
  default     = "eu-west-1b"
}
variable "az3" {
  description = "Availability Zone 3"
  type        = string
  default     = "eu-west-1c"
}
variable "private_subnet_1" {
  description = "Private subnet AZ1"
  type        = string
  default     = "10.0.7.0/24"
}
variable "private_subnet_2" {
  description = "Private subnet AZ2"
  type        = string
  default     = "10.0.8.0/24"
}
variable "private_subnet_3" {
  description = "Private subnet AZ3"
  type        = string
  default     = "10.0.9.0/24"
}
variable "public_subnet_1" {
  description = "Public subnet AZ1"
  type        = string
  default     = "10.0.107.0/24"
}
variable "public_subnet_2" {
  description = "Public subnet AZ2"
  type        = string
  default     = "10.0.108.0/24"
}
variable "public_subnet_3" {
  description = "Public subnet AZ3"
  type        = string
  default     = "10.0.109.0/24"
}
variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
variable "vpc_name" {
  description = "Common name for the VPC"
  type        = string
  default     = "zdriv-vpc"
}
