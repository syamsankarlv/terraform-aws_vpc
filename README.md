# AWS_VPC Creation Using Terraform 
 
## Create a VPC Through Terraform (Fully Automated Script)
[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)
 
## Description.
 
Terraform is a tool for building infrastructure with various technologies including Amazon AWS, Microsoft Azure, Google Cloud, and vSphere.
 
Here is a simple document on how to use Terraform to build an AWS VPC along with private/public Subnet and Network Gateway's for the VPC.
We will be making 1 VPC with 6 Subnets: 3 Private and 3 Public, 1 NAT Gateways, 1 Internet Gateway, and 2 Route Tables all the creation was automated with appending to your values.
 
## Terraform Installation Link ##
 
For Downloading - [Terraform](https://developer.hashicorp.com/terraform/install)
 
Installation Steps -[Installation](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli?in=terraform%2Faws-get-started)

 
### Features
- Fully Automated creation of VPC
- It can be deployed in any region and will be fetching the available zones in that region automatically using data source AZ.
- Public and private subnets will be deployed in each AZ in an automated way.
- Every subnet CIDR block has been calculated automatically using cidrsubnet function
- The key components of the entire project are passed through the "variables.tf" file. This file facilitates streamlined management, including selecting the region, comprehensively modifying the project name, choosing the VPC, and configuring subnetting.
 
### Prerequisites for this project
- Need a IAM user access with attached policies for the creation of VPC.
- Understanding the operational principles of essential AWS services such as VPC, EC2, and IP subnetting is vital for proficiently architecting and managing cloud infrastructure.

### Passing IAM key's into Environment Variable ###

Here, I'm using environment variables to pass the AWS keys in Terraform. However, there is another method we can utilize. I'll outline the pros and cons of both setups below.

Both methods have their advantages and considerations when it comes to security and professionalism:

### Environment variables:

#### Advantages:

 - Can be set dynamically, which is useful for automation and CI/CD pipelines.
 - Easy to manage and change without altering Terraform configuration files.
 - Reduced risk of accidental exposure compared to files stored on disk.

#### Considerations:

 - Can clutter the environment if many variables are needed.
 - May not be as centralized or version-controlled as terraform.tfvars.
 - Proper access control mechanisms are necessary to prevent unauthorized access.

#### Terraform.tfvars:

#### Advantages:

 - Organized and centralized storage of sensitive information.
 - Easily version-controlled along with your Terraform configuration.
 - Can be encrypted at rest using tools like Vault or AWS KMS.

####  Considerations:
 - Needs to be managed securely to prevent unauthorized access.
 - Possibility of accidental exposure if not properly protected or shared.
    

- Powershell CMD
```sh
$env:TF_VAR_aws_access_key = "your-access-key"
$env:TF_VAR_aws_secret_key = "your-secret-key"
$env:TF_VAR_aws_region = "region"
```
- Linux CMD
```sh
export TF_VAR_aws_access_key="your-access-key"
export TF_VAR_aws_secret_key="your-secret-key"
export TF_VAR_aws_region="region"
```
### Terraform Code Explanation

Here is the variable.tf file with the list of variables for the creation of VPC.
```sh                                                     
 variable "aws_access_key" {
  type        = string
  description = "AWS Access Key"
  sensitive   = true

}

variable "aws_secret_key" {
  type        = string
  description = "AWS Secret Key"
  sensitive   = true

}

variable "aws_region" {
  default = "us-east-2"

}

variable "project" {
  default = "Terraform"

}

variable "vpc_cidr" {
  default = "172.16.0.0/16"

}

variable "aws_route_table" {
  description = "Public & Private Route-table"
  default     = "0.0.0.0/0"

}
```
## Provider file

Next proceeds with the creation of the provider file with passing  variables from "variables.tf" and the file name here is that provider.tf

```sh
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region

}
```

## VPC Creation

```sh
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
```

## Internet GateWay
```sh
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-igw"
    project = var.project
  }
}
```
## Subnet

Here, I have configured 3 public Subnet and 3 private Subnet.

- ### Public Subnet -1
```sh
resource "aws_subnet" "Public-1" {

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, 0)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.az.names[0]

  tags = {
    Name    = "${var.project}-public-1"
    project = var.project
  }
}
```
- ### Public Subnet -2
```sh
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
```
- ### Public Subnet -3
```sh
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
```
- ### Private Subnet -1
```sh
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
```
- ### Private Subnet -2
```sh
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
```
- ### Private Subnet -3
```sh
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
```

## Elastic IP allocation

Creating Elastic IP For Nat Gateway

```sh
resource "aws_eip" "eip" {
  domain = "vpc"
  tags = {
    Name    = "${var.project}-nat-eip"
    project = var.project

  }
}
```

##  NAT Gatway

Attaching Elastic IP to NAT gateway

```sh
resource "aws_nat_gateway" "nat" {

  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.Public-2.id

  tags = {
    Name    = "${var.project}-nat"
    project = var.project
  }

}
```

## Route Table

- ### Route Table - Public
```sh
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
```
- ### Route Table - Private
```sh
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
```

## Public Route table Association

```sh
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.Public-1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.Public-2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public3" {
  subnet_id      = aws_subnet.Public-3.id
  route_table_id = aws_route_table.public.id
}
```

## Private Route table Association

```sh
resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.Private-1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.Private-2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private3" {
  subnet_id      = aws_subnet.Private-3.id
  route_table_id = aws_route_table.private.id
}
```

## User Instructions

- Clone the git repo
- Update the values of the variables as per the requirements.
- Before initializing, you need to provide the AWS key. Depending on your organization's security policies, you can configure this accordingly.
- After completing these, initialize the working directory for Terraform configuration using the below command.

```sh
terraform init
```

- Validate the terraform file using the command given below.
```sh
terraform validate
```
- After successful validation, plan the build architecture and confirm the changes
```sh
terraform plan
```
- Apply the changes to the AWS architecture.
```sh
terraform apply
```

## Conclusion

Here is a simple document on how to use Terraform to build an AWS VPC along with private/public Subnet and Network Gateway's for the VPC. We will be making 1 VPC with 6 Subnets: 3 Private and 3 Public, 1 NAT Gateways, 1 Internet Gateway, and 2 Route Tables all the creation was automated with appending to your values.


### ⚙️ Connect with Me

<p align="center">
    <a href="mailto:sankarlvsyam@gmail.com"><img src="https://img.shields.io/badge/Gmail-D14836?style=for-the-badge&logo=gmail&logoColor=white" alt="Gmail"/></a>
    <a href="https://www.linkedin.com/in/syam-sankar-l-v-06bb68119/"><img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white" alt="LinkedIn"/></a>
</p>
