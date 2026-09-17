output "id" {
  description = "Organizational Unit ID"
  value       = aws_organizations_organizational_unit.this.id
}

output "arn" {
  description = "Organizational Unit ARN"
  value       = aws_organizations_organizational_unit.this.arn
}