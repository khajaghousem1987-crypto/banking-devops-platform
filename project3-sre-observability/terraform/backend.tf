terraform { backend "s3" { bucket="banking-infra" key="project3-sre-observability/terraform.tfstate" region="us-east-1" encrypt=true } }
