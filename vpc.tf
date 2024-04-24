#####################################-AWS-INFRA-SETUP-#######################################

#  ===============================
#          VPC Setup 
#  ===============================

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name    = "${var.project}-vpc"
    project = var.project
  }

}

#  ===============================
#        Fetching AZ's Name
#  ===============================

data "aws_availability_zones" "az" {
  state = "available"

}

#  ===============================
#    Attach aws_internet_gateway
#  ===============================


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-igw"
    project = var.project
  }
}

#  ===============================
#    Creating Subnets
#  ===============================


#### Subnet-Public-1 ####

resource "aws_subnet" "Public-1" {

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, 0) #Eg: cidrsubnet (172.16.0.0/12, 4, 2)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.az.names[0]

  tags = {
    Name    = "${var.project}-public-1"
    project = var.project
  }
}

#### Subnet-Public-2 ####

resource "aws_subnet" "Public-2" {

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, 1)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.az.names[1]
  tags = {
    Name    = "${var.project}-public-2"
    project = var.project
  }
}

#### Subnet-Public-3 ####

resource "aws_subnet" "Public-3" {

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, 2)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.az.names[2]

  tags = {
    Name    = "${var.project}-public-3"
    project = var.project
  }
}


#### Subnet-Private-1 ####

resource "aws_subnet" "Private-1" {

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, 3)
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.az.names[0]

  tags = {
    Name    = "${var.project}-private-1"
    project = var.project
  }
}

#### Subnet-Private-2 ####

resource "aws_subnet" "Private-2" {

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, 5)
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.az.names[1]

  tags = {
    Name    = "${var.project}-private-2"
    project = var.project
  }
}

#### Subnet-Private-3 ####

resource "aws_subnet" "Private-3" {

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, 6)
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.az.names[2]

  tags = {
    Name    = "${var.project}-private-3"
    project = var.project
  }
}

#  ===============================
#    Elastic IP allocation
#  ===============================

resource "aws_eip" "eip" {
  domain = "vpc"
  tags = {
    Name    = "${var.project}-nat-eip"
    project = var.project

  }
}

#  ===============================
#    NAT Gatway
#  ===============================

resource "aws_nat_gateway" "nat" {

  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.Public-2.id

  tags = {
    Name    = "${var.project}-nat"
    project = var.project
  }

}

#  ===============================
#    RouteTable creation public
#  ===============================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.aws_route_table
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name    = "${var.project}-route-public"
    project = var.project
  }
}

#  ===============================
#    RouteTable creation Private
#  ===============================

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = var.aws_route_table
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name    = "${var.project}-route-private"
    project = var.project
  }
}

#  ====================================================
#    Routetable Association subnet public-1  rtb public
#  ====================================================

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.Public-1.id
  route_table_id = aws_route_table.public.id
}

#  ====================================================
#    Routetable Association subnet public-2  rtb public
#  ====================================================

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.Public-2.id
  route_table_id = aws_route_table.public.id
}

#  ====================================================
#    Routetable Association subnet public-3  rtb public
#  ====================================================


resource "aws_route_table_association" "public3" {
  subnet_id      = aws_subnet.Public-3.id
  route_table_id = aws_route_table.public.id
}

#  ====================================================
#    Routetable Association subnet Private-1  rtb public
#  ====================================================


resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.Private-1.id
  route_table_id = aws_route_table.private.id
}

#  ====================================================
#    Routetable Association subnet Private-2  rtb public
#  ====================================================

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.Private-2.id
  route_table_id = aws_route_table.private.id
}

#  ====================================================
#    Routetable Association subnet Private-3  rtb public
#  ====================================================

resource "aws_route_table_association" "private3" {
  subnet_id      = aws_subnet.Private-3.id
  route_table_id = aws_route_table.private.id
}

#####################################-END-#######################################

