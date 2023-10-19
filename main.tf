#configure provider
#resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/resource-tagging
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region
  #profile = "Admin"
}

# configure vpc
#resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "D5_1_VPC" {
  cidr_block              = "10.0.0.0/16"
  instance_tenancy        = "default"
  enable_dns_hostnames    = true

  tags      = {
    Name    = var.vpc_name
  }
}

#configure subnets within vpc
#resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets
# Create a subnet within the VPC

resource "aws_subnet" "D5_1_VPC_Subnet_A" {
  vpc_id                  = aws_vpc.D5_1_VPC.id 
  cidr_block              = "10.0.2.0/24"
  availability_zone       = var.availability_zone_A
  map_public_ip_on_launch = true

  tags      = {
    Name    = var.pub_subnetA_name
  }
}

# Create a subnet within the VPC
resource "aws_subnet" "D5_1_VPC_Subnet_B" {
  vpc_id                  = aws_vpc.D5_1_VPC.id 
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.availability_zone_B
  map_public_ip_on_launch = true

  tags      = {
    Name    = var.pub_subnetB_name
  }
}

# Create instance to configure Jenkins server
# resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "D5_1_Jenkins_Server" {
  ami = var.ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.D5_1_VPC_Subnet_A.id
  security_groups = [aws_security_group.D5_1SG_Jenkins_Server.id]
  key_name = var.key_name

  user_data = "${file("deploy.sh")}"

  tags = {
    "Name" : var.instance_A_name
  }

}

# Create instance to configure application1 server
# resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "D5_1_APP1_Server" {
  ami = var.ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.D5_1_VPC_Subnet_A.id
  security_groups = [aws_security_group.D5_1SG_APP2_Server.id]
  key_name = var.key_name

  
  tags = {
    "Name" : var.instance_B_name
  }

}

# Create instance to configure application2 server
# resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "D5_1_APP2_Server" {
  ami = var.ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.D5_1_VPC_Subnet_B.id
  security_groups = [aws_security_group.D5_1SG_APP2_Server.id]
  key_name = var.key_name

  tags = {
    "Name" : var.instance_C_name
  }

}

#configure internet gateway
#resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "D5_1igw" {
  vpc_id = aws_vpc.D5_1_VPC.id

  tags = {
    Name = var.igw_name
  }
}


#configure route table
#resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "D5_1_route_table" {
  vpc_id = aws_vpc.D5_1_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.D5_1igw.id
  }

  tags = {
    Name = var.route_table_name
  }
}


#associate route table with subnets
#resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association

resource "aws_route_table_association" "D5_1_RTA_Subnet_A" {
  subnet_id      = aws_subnet.D5_1_VPC_Subnet_A.id
  route_table_id = aws_route_table.D5_1_route_table.id
}

resource "aws_route_table_association" "D5_1_RTA_Subnet_B" {
  subnet_id      = aws_subnet.D5_1_VPC_Subnet_B.id
  route_table_id = aws_route_table.D5_1_route_table.id
}


output "instance_ips" {
  description = "IDs of the instances created"
  value = {
    Jenkins_server_instance = aws_instance.D5_1_Jenkins_Server.id,
    APP1_server_instance = aws_instance.D5_1_APP1_Server.id,
    APP2_server_instance = aws_instance.D5_1_APP2_Server.id
  }
} 


#create security groups
#resource https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "D5_1SG_Jenkins_Server" {
  name        = "D5_1SG_Jenkins_Server"
  description = "open ssh traffic"
  vpc_id = aws_vpc.D5_1_VPC.id 


  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

    ingress {
    from_port = 8000
    to_port = 8000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" : var.security_groups_name
    "Terraform" : "true"
  }

}

resource "aws_security_group" "D5_1SG_APP1_Server" {
  name        = "D5_1SG_APP1_Server"
  description = "open ssh traffic"
  vpc_id = aws_vpc.D5_1_VPC.id 


  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

    ingress {
    from_port = 8000
    to_port = 8000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" : var.security_groups_name
    "Terraform" : "true"
  }

}


resource "aws_security_group" "D5_1SG_APP2_Server" {
  name        = "D5_1SG_APP2_Server"
  description = "open ssh traffic"
  vpc_id = aws_vpc.D5_1_VPC.id 


  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

    ingress {
    from_port = 8000
    to_port = 8000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" : var.security_groups_name
    "Terraform" : "true"
  }

}
