output "vpc_id" {
  value = aws_vpc.main.id
}
output "public_subnet_ids" {

  description = "List of Public Subnet IDs"

  value = [
    aws_subnet.public1.id,
    aws_subnet.public2.id
  ]
}

output "private_subnet_ids" {

  description = "List of Private Subnet IDs"

  value = [
    aws_subnet.private1.id,
    aws_subnet.private2.id
  ]
}
output "nat_gateway_id" {
  value = aws_nat_gateway.this.id
}