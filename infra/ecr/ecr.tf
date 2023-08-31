terraform {
  backend "s3" {
      bucket         = "tf-state-fastapi-demo"
      key            = "ecr/terraform.tfstate"
      region         = "us-east-1"
      dynamodb_table = "terraform-state-locking"
      encrypt        = true
    }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}



##### ECR REPO
resource "aws_ecr_repository" "my_fastapi_app" {
  name = "my-fastapi-app"
}

output "ecr_repository_uri" {
  value = aws_ecr_repository.my_fastapi_app.repository_url
}

output "instance_public_ip" {
  value = aws_instance.web_instance.public_ip
}