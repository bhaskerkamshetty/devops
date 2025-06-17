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
  region  = "ap-south-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-05a5bb48beb785bf1"
  instance_type = "t2.micro"
  key_name	= "existing-key-name"

  tags = {
    Name = "IAC-Example"
  }
}
