terraform {
  backend "s3" {
      bucket         = "tf-state-aaron"
      key            = "fastapi-demo/tf-backend/terraform.tfstate"
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


##### NETWORKING
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.my_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

resource "aws_route_table_association" "subnet_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}


##### INSTANCE SECURITY
resource "aws_security_group" "instance_sg" {
  name_prefix = "instance-sg-"
  vpc_id      = aws_vpc.my_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

##### ECR ACCESS FROM EC2
resource "aws_iam_policy" "ecr_pull_policy" {
  name = "ECR-Pull-Policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetAuthorizationToken"
        ],
        Resource = "*"
      }
    ],
  })
}

resource "aws_iam_role" "ecr_role" {
  name = "ECR-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole",
      }
    ],
  })
}

resource "aws_iam_role_policy_attachment" "ecr_role_policy_attachment" {
  policy_arn = aws_iam_policy.ecr_pull_policy.arn
  role       = aws_iam_role.ecr_role.name
}

resource "aws_iam_instance_profile" "ecr_instance_profile" {
  name = "ECR-Instance-Profile"
  role = aws_iam_role.ecr_role.name
}


##### INSTANCE
resource "aws_instance" "web_instance" {
  ami           = "ami-08a52ddb321b32a8c"
  instance_type = "t2.micro"
  key_name      = "aaron-demo"
  subnet_id     = aws_subnet.my_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ecr_instance_profile.name

  user_data = <<-EOF
    #!/bin/bash
    set -ex
    sudo yum update -y
    sudo yum install docker -y
    sudo service docker start
    sudo usermod -aG docker ec2-user
    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 806152608109.dkr.ecr.us-east-1.amazonaws.com
    docker pull 806152608109.dkr.ecr.us-east-1.amazonaws.com/my-fastapi-app:latest
    docker run -d -p 8000:8000 806152608109.dkr.ecr.us-east-1.amazonaws.com/my-fastapi-app:latest
  EOF


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