output "policy_id" {
  description = "ID of the Service Control Policy"
  value       = aws_organizations_policy.this.id
}

output "policy_arn" {
  description = "ARN of the Service Control Policy"
  value       = aws_organizations_policy.this.arn
}