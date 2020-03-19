terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "bowdoincollege"
    workspaces {
      name = "noc-networktest-aws"
    }
  }
}

provider "aws" {
  region  = local.aws_region[var.region]
  version = "~> 2.0"
}

locals {
  aws_region = {
    usea1 = "us-east-1"
    uswe1 = "us-west-1"
  }
  azs = ["a", "b"]
}

resource "aws_vpc" "this" {
  cidr_block                       = "10.224.20.0/22"
  assign_generated_ipv6_cidr_block = true
  tags = {
    Name = "networktest-vpc"
  }
}

resource "aws_subnet" "public" {
  for_each        = { for az in local.azs : az => az }
  vpc_id          = aws_vpc.this.id
  cidr_block      = cidrsubnet(aws_vpc.this.cidr_block, 4, index(local.azs, each.key))
  ipv6_cidr_block = cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, index(local.azs, each.key))
}
