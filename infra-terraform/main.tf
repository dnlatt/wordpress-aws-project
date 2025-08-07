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

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

# Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Route Table
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

# Route Table Association
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group
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

# IAM Role for EC2 SSM
resource "aws_iam_role" "ssm_role" {
  name = "EC2SSMRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "EC2SSMInstanceProfile"
  role = aws_iam_role.ssm_role.name
}

# EC2 Instance with User Data to install WordPress
resource "aws_instance" "wordpress" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ssm_instance_profile.name
  associate_public_ip_address = true

  user_data = <<-EOF
                #!/bin/bash
                set -e

                # Log script start
                echo "Starting cloud-init user data script..."

                # Update package lists and install all required software.
                apt-get update -y
                apt-get install -y git docker.io docker-compose ca-certificates curl gnupg

                # Ensure the 'docker' group exists before adding the user.
                if ! getent group docker > /dev/null; then
                    groupadd docker
                fi

                # Add the 'ubuntu' user to the 'docker' group to allow running Docker commands without sudo.
                usermod -aG docker ubuntu

                # Start and enable the Docker service.
                systemctl enable docker
                systemctl start docker

                # Go to the 'ubuntu' user's home directory.
                cd /home/ubuntu

                # Clone the project repository.
                echo "Cloning the WordPress repository..."
                sudo -u ubuntu git clone https://github.com/dnlatt/wordpress-aws-project.git

                # Navigate into the specific directory that contains docker-compose.yml
                
                cd /home/ubuntu/wordpress-aws-project/wordpress-docker/build

                # Run docker-compose up as the 'ubuntu' user
                echo "Running docker-compose..."
                sudo -u ubuntu docker-compose up -d

                echo "User data script finished successfully."

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

# CloudWatch Logs Group
resource "aws_cloudwatch_log_group" "wordpress_log_group" {
  name              = "/wordpress/app"
  retention_in_days = 1
}
