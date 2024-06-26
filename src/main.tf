terraform {

#   store credential e.g. tfstate in Terraform cloud is a best practice of security.
  # cloud {
  #   organization = "terraform_cloud_Org_name"
  #   workspaces {
  #     name = "workspace_name
  #   }
  # }
  #

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}


# 
provider "aws" {
  # profile = "aws_account_profile_name"
  region  = "ap-southeast-1"
}

# "resource_type" "resource_name"
resource "aws_vpc" "default_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Default VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.default_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.default_vpc.id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.default_vpc.id
  tags = {
    Name = "Public Subnet Route Table"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"

  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "web_server_sg" {
  name        = "web-security-group"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.default_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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


# you can use either variables from cloud settings or variable.tf. .
resource "aws_instance" "web_server" {
  subnet_id                   = aws_subnet.public_subnet.id
  ami                         = var.INSTANCE_AMI
  instance_type               = var.INSTANCE_TYPE
  associate_public_ip_address = true
  security_groups = [aws_security_group.web_server_sg.id]
  tags = {
    Name = var.INSTANCE_NAME
  }
}

