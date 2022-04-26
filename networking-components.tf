### VPC ###

resource "aws_vpc" "nginx_vpc" {
  cidr_block           = var.nginx_vpc
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = true
  enable_dns_hostnames = true
}

### PUBLIC SUBNETS ###

resource "aws_subnet" "public_subnet" {
  count             = var.nginx_vpc == "10.0.0.0/16" ? 3 : 0
  vpc_id            = aws_vpc.nginx_vpc.id
  availability_zone = data.aws_availability_zones.azs.names[count.index]
  cidr_block        = element(cidrsubnets(var.nginx_vpc, 8, 4, 4), count.index)
}

### INTERNET GATEWAY ###

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.nginx_vpc.id

  tags = {
    "Name" = "internet gateway"
  }
}

### PUBLIC ROUTE TABLE ###

resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.nginx_vpc.id

  tags = {
    "Name" = "Public Route Table"
  }
}

### PUBLIC ROUTE ###

resource "aws_route" "pub_route" {
  count                  = length(aws_route_table.pub_rt.*.id)               // added this line to produce correct route table
  route_table_id         = element(aws_route_table.pub_rt.*.id, count.index) //changed from "aws_route_table.pub_rt.id"  
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

### PUBLIC ROUTE TABLE ASSOC. ###

resource "aws_route_table_association" "pub_route_table_association" {
  count          = length(aws_subnet.public_subnet) == 3 ? 3 : 0
  route_table_id = aws_route_table.pub_rt.id
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
}

