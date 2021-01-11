# Provider
provider "aws" {
  region      = var.region
}

# vpc 
resource "aws_vpc" "trimble_main" {
  cidr_block = "10.0.0.0/22"
  enable_dns_hostnames = true
  tags { 
    Name = "trimble" 
  }
}