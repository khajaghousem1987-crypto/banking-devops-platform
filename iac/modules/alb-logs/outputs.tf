output "bucket_name" {
  description = "Name of the ALB access logs S3 bucket"
  value       = aws_s3_bucket.alb_logs.id
}

output "bucket_arn" {
  description = "ARN of the ALB access logs S3 bucket"
  value       = aws_s3_bucket.alb_logs.arn
}