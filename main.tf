##############################################
# Create the main VPC
##############################################
resource "aws_vpc" "terraform_electron_vpc" {
  cidr_block = var.vpc_cidr                # Define the IP range for the VPC (e.g., 10.0.0.0/16)
  tags = {
    Name = "terraform-electron-vpc"        # Tag to identify this VPC in the AWS console
  }
}

##############################################
# Create the Public Subnet
##############################################
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.terraform_electron_vpc.id  # Attach the subnet to the VPC
  cidr_block = var.public_subnet_cidr             # Define subnet IP range (e.g., 10.0.1.0/24)

  tags = {
    Name = "Public-Subnet"                        # Tag for the public subnet
  }
}

##############################################
# Create the Private Subnet
##############################################
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.terraform_electron_vpc.id  # Attach to the same VPC
  cidr_block = var.private_subnet_cidr            # Define IP range (e.g., 10.0.2.0/24)

  tags = {
    Name = "Private-Subnet"                       # Tag for the private subnet
  }
}

##############################################
# Create an Internet Gateway (IGW)
##############################################
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.terraform_electron_vpc.id      # Attach the IGW to the VPC

  tags = {
    Name = "terraform-electron-igw"               # Tag for the IGW
  }
}

##############################################
# Create an Elastic IP (EIP) for NAT Gateway
##############################################
resource "aws_eip" "lb" {
  domain = "vpc"                                  # Ensure the EIP is allocated for a VPC
}

##############################################
# Create the NAT Gateway (for private subnet internet access)
##############################################
resource "aws_nat_gateway" "NAT_Gateway" {
  allocation_id = aws_eip.lb.id                   # Link the EIP to the NAT Gateway
  subnet_id     = aws_subnet.public_subnet.id     # NAT Gateway must be in a public subnet

  tags = {
    Name = "terraform-electron-nat-gateway"       # Tag for the NAT Gateway
  }

  # Force Terraform to create the Internet Gateway first
  depends_on = [aws_internet_gateway.internet_gateway]
}

##############################################
# Create Route Table for the Public Subnet
##############################################
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.terraform_electron_vpc.id

  # Route all outbound traffic (0.0.0.0/0) to the Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "public-route-table"                   # Tag for the route table
  }
}

##############################################
# Associate Public Subnet with Public Route Table
##############################################
resource "aws_route_table_association" "public-route-table-association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

##############################################
# Create Route Table for the Private Subnet
##############################################
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.terraform_electron_vpc.id

  # Route all outbound traffic through the NAT Gateway
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT_Gateway.id
  }

  tags = {
    Name = "private-route-table"                  # Tag for the route table
  }
}

##############################################
# Associate Private Subnet with Private Route Table
##############################################
resource "aws_route_table_association" "private-route-table-association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}




##############################################
# Security Group for Public EC2 Instance
##############################################
resource "aws_security_group" "terraform-electron-security-group" {
  name        = "terraform-electron-security-group"
  description = "Allow SSH from anywhere"
  vpc_id      = aws_vpc.terraform_electron_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # ⚠️ open to all, restrict later for security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-electron-security-group"
  }
}

##############################################
# EC2 Instance in Public Subnet
##############################################
resource "aws_instance" "terraform-electron-ec2" {
  ami                    = "ami-0c02fb55956c7d316" # ✅ Amazon Linux 2 - us-east-1
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.terraform-electron-security-group.id]
  associate_public_ip_address = true
  key_name               = "saif-key" # Make sure you've created this key pair in AWS Console

  tags = {
    Name = "terraform-electron-ec2"
  }
}


























##############################################
# 🌐 AWS NETWORK DIAGRAM (Full Setup with Associations)
#
#                    ┌────────────────────────────┐
#                    │         Internet           │
#                    └────────────┬───────────────┘
#                                 │
#                      (0.0.0.0/0 via IGW)
#                                 │
#                 ┌───────────────┴───────────────┐
#                 │   Internet Gateway (IGW)      │
#                 │   igw-xxxxxxxxxxxxxxxxx       │
#                 └───────────────┬───────────────┘
#                                 │
#              ┌──────────────────┴──────────────────┐
#              │           Public Subnet (10.0.1.0/24) │
#              │           subnet-xxxxxxxxxxxxxxxxx    │
#              │                                       │
#              │  ➜ Associated with:                   │
#              │      Public Route Table (rtb-public)  │
#              │      └ Route: 0.0.0.0/0 → IGW         │
#              │                                       │
#              │  🔸 This allows Public Subnet instances
#              │     to reach the Internet directly.
#              └──────────────────┬──────────────────┘
#                                 │
#                  NAT Gateway (nat-xxxxxxxxxxxxxxxx)
#                  Elastic IP → 34.xxx.xxx.xxx
#                  └ Depends on IGW for Internet access
#                                 │
#                 (0.0.0.0/0 traffic via NAT Gateway)
#                                 │
#              ┌──────────────────┴──────────────────┐
#              │          Private Subnet (10.0.2.0/24) │
#              │          subnet-xxxxxxxxxxxxxxxxx     │
#              │                                       │
#              │  ➜ Associated with:                   │
#              │      Private Route Table (rtb-private)│
#              │      └ Route: 0.0.0.0/0 → NAT Gateway │
#              │                                       │
#              │  🔸 This allows Private Subnet instances
#              │     to reach the Internet via NAT GW only.
#              └──────────────────┬──────────────────┘
#                                 │
#                     Private EC2 Instance
#                     (No Public IP — Internet via NAT)
#
# 🔹 Summary:
# - Public Route Table → sends Internet traffic to IGW
# - Private Route Table → sends Internet traffic to NAT GW
# - Each subnet must be ASSOCIATED with its Route Table:
#     • Public Subnet ↔ Public Route Table
#     • Private Subnet ↔ Private Route Table
# - IGW provides Internet to Public Subnet.
# - NAT GW provides Internet access for Private Subnet.
# - EIP assigned to NAT GW for outbound traffic.
# - Security Groups control access to EC2 instances.
# - Key Pairs enable SSH access to EC2 instances.
#   - Ensure you have the private key file (.pem) to connect.
#   - Use the following command to connect:
#     ssh -i /path/to/saif-key.pem ec2-user@<Public-IP-of-EC2>
#   ssh -i ~/.ssh/saif-key.pem ec2-user@100.27.207.27
##############################################

