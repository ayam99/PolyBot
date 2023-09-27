terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.16"
    }
  }
  
  backend "s3" {
    bucket = "ayamal-dev-bucket"
    key    = "tfstate.json"
    region = "us-east-1"
  }

  required_version = ">= 1.0.0"
}

provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available_azs" {
  state = "available"
}

locals {
  # Ids for multiple sets of EC2 instances, merged together
  az_list = data.aws_availability_zones.available_azs.names
}

resource "aws_instance" "web" {
  ami           = "ami-04dcb3dba9a01fa63"
  instance_type = var.env == "prod" ? "t2.micro" : "t2.nano"
  vpc_security_group_ids = [aws_security_group.securityg_web.id]
 
  depends_on = [
   aws_s3_bucket.data_bucket
]

  tags = {
    Name = "${var.resource_alias}-${var.env}"
    Terraform =  true
  }
  
}

resource "aws_subnet" "subnet1" {
  vpc_id     = module.app_vpc.vpc_id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Env         = var.env
    Terraform   = true
  }
  
}

resource "aws_subnet" "subnet2" {
  vpc_id     = module.app_vpc.vpc_id
  cidr_block = "10.0.5.0/24"
  availability_zone   = "us-east-1c" 

  tags = {
    Env         = var.env
    Terraform   = true
  }
}

resource "aws_s3_bucket" "data_bucket" {
  bucket = "${var.resource_alias}-${var.env}-bucket"

  tags = {
    Name        = "${var.resource_alias}-bucket"
    Env         = var.env
    Terraform   = true
  }
}

resource "aws_security_group" "securityg_web" {
  name = "${var.resource_alias}-${var.env}-securityg"

  ingress {
    from_port   = "8080"
    to_port     = "8080"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Env         = var.env
    Terraform   = true
  }
}

resource "aws_lb_target_group" "target_group" {
  name     = "lb-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = module.app_vpc.vpc_id
}


resource "aws_lb" "loadbalancer_web" {

  name  = "${var.resource_alias}-alb"
  internal  = false
  load_balancer_type = "network"
  subnets = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]


  enable_deletion_protection = true
  
  
  tags = {
    Env       = var.env
    Terraform = true
  }
}

module "app_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  name = "${var.resource_alias}-vpc"
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets
  
  enable_nat_gateway = false

  tags = {
    Name        = "${var.resource_alias}-vpc"
    Env         = var.env
    Terraform   = true
  }
}
