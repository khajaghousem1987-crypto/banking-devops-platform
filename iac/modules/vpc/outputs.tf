output "vpc_id" {
 value = aws_vpc.main.id
}
output "public_subnet_1" {
 value = aws_subnet.public1.id
}
output "public_subnet_2" {
 value = aws_subnet.public2.id
}
output "private_subnet_1" {
 value = aws_subnet.private1.id
}
output "private_subnet_2" {
 value = aws_subnet.private2.id
}

output "nat_gateway_id" {
 value = aws_nat_gateway.this.id
}