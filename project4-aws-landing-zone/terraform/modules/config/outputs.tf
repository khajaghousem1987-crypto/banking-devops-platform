output "bucket_name" {
  value = aws_s3_bucket.config.id
}

output "recorder_name" {
  value = aws_config_configuration_recorder.this.name
}

output "delivery_channel_name" {
  value = aws_config_delivery_channel.this.name
}