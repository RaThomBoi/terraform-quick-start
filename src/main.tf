terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "ap-southeast-1"
  profile = "720133173047_NetworkAdministrator"
}

#  "resource_type" "resource_name"
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
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_instance" "app_server" {
  subnet_id     = aws_subnet.public_subnet.id
  ami           = "ami-0910e4162f162c238"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

