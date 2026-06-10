# Copyright (c) 2026 mingju.xu (xumj1125@live.com). All rights reserved.
# Licensed under the GNU General Public License v3.0.

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "rds_endpoint" {
  description = "The connection endpoint for the RDS PostgreSQL database"
  value       = aws_db_instance.postgres.endpoint
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket created for artifacts"
  value       = aws_s3_bucket.artifacts.id
}
