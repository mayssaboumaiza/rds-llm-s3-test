output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint (host:port)"
  value       = aws_db_instance.postgres.endpoint
}

output "rds_db_name" {
  description = "PostgreSQL database name"
  value       = aws_db_instance.postgres.db_name
}

output "s3_bucket_name" {
  description = "Name of the S3 exports bucket"
  value       = aws_s3_bucket.exports.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 exports bucket"
  value       = aws_s3_bucket.exports.arn
}

output "app_iam_role_arn" {
  description = "ARN of the IAM role for the application"
  value       = aws_iam_role.app.arn
}
