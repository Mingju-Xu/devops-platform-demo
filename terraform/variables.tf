# Copyright (c) 2026 mingju.xu (xumj1125@live.com). All rights reserved.
# Licensed under the GNU General Public License v3.0.

variable "region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, prod)"
  type        = string
  default     = "dev"
}

variable "db_password" {
  description = "The password for the RDS PostgreSQL database"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "The instance class of the RDS database"
  type        = string
  default     = "db.t3.micro"
}
