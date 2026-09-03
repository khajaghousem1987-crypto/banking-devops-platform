output "repository_name" {

  value = aws_ecr_repository.banking_app.name

}

output "repository_url" {

  value = aws_ecr_repository.banking_app.repository_url

}
 