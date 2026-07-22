output "security_group_id" {
 
  description = "Application Security Group ID"
 
  value = aws_security_group.banking_app_sg.id
}
 
output "security_group_name" {
 
  description = "Application Security Group Name"
 
  value = aws_security_group.banking_app_sg.name
}