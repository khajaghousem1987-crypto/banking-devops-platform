output "bucket_name" {
  value = aws_s3_bucket.cloudtrail.id
}

output "bucket_arn" {
  value = aws_s3_bucket.cloudtrail.arn
}

output "trail_name" {
  value = aws_cloudtrail.this.name
}

output "trail_arn" {
  value = aws_cloudtrail.this.arn
}