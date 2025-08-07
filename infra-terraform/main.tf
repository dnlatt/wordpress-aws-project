terraform {
  cloud {
    organization = "Latt"

    workspaces {
      name = "wordpress-aws-project"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}

# Create a public subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-route"
  }
}

# Associate subnet with route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security group for EC2
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM Role for EC2 to access S3
resource "aws_iam_role" "ec2_role" {
  name = "ec2-s3-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach S3 full access policy
resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Instance profile for EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-s3-profile"
  role = aws_iam_role.ec2_role.name
}

# EC2 instance with UserData to install WordPress
resource "aws_instance" "wordpress" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true
  key_name                    = "your-key-pair-name" # Replace with your key

  user_data = <<-EOF

                #!/bin/bash
                yum update -y

                # Install git, docker
                yum install -y git docker

                # Start and enable docker service
                systemctl enable docker
                systemctl start docker

                # Install docker-compose binary
                curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
                chmod +x /usr/local/bin/docker-compose

                # Add ec2-user to docker group so no sudo needed
                usermod -aG docker ec2-user

                # Change directory to ec2-user home
                cd /home/ec2-user

                # If repo not cloned yet, clone it (replace with your git repo)
                if [ ! -d "wordpress-docker" ]; then
                sudo -u ec2-user git clone https://github.com/dnlatt/wordpress-aws-project.git
                fi

                cd wordpress-docker

                # Run docker-compose (use ec2-user)
                sudo -u ec2-user docker-compose up -d

            EOF

  tags = {
    Name = "aws-wordpress-instance"
  }
}

# S3 Bucket
resource "aws_s3_bucket" "wordpress_bucket" {
  bucket = var.bucket_name

  tags = {
    Name = "aws-wordpress-s3-bucket"
  }
}

# CloudWatch Logs Group (basic setup)
resource "aws_cloudwatch_log_group" "wordpress_log_group" {
  name              = "/wordpress/app"
  retention_in_days = 1
}
