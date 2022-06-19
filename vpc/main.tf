#Set up the provider
provider "aws" {
  region = "eu-west-1"
}


#Create the VPC
 resource "aws_vpc" "main" {                # Creating VPC here
   cidr_block       = "10.2.0.0/16"     # Defining the CIDR block use 10.0.0.0/24 for demo
   instance_tenancy = "default"
 
tags = {
    Name = "vpc-tf"
  }
}


#Create an Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}


#Create a Subnet
resource "aws_subnet" "main" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.2.1.0/24"

  tags = {
    Name = "subnet-tf"
  }
}

###################################################################################################################


#Create a Route Table and then associate it with the Subnet
resource "aws_route_table" "default" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "main" { 
  subnet_id = aws_subnet.main.id
  route_table_id = aws_route_table.default.id
}

###################################################################################################################


#Create Elastic IP for our NAT Gateway
resource "aws_eip" "eip" {
  instance = aws_instance.server.id
  vpc = true
  depends_on = [aws_internet_gateway.main] # Bloque "depende de" --> si el Gateway no existe, la IP elástica tampoco
 }


#Create a NAT Gateway
#resource "aws_nat_gateway" "natgw" {
 # allocation_id = aws_eip.eip.id
  #subnet_id = aws_subnet.main.id

 # tags = {
 #   Name = "gw NAT"
 # }

 # depends_on = [aws_internet_gateway.main] # Si no existe el Gateway de Internet, no existe el NAT GW
#}


#Create SSH key for our EC2 instance
resource "aws_key_pair" "tf_key" {
  key_name = "tf_key"
  public_key = tls_private_key.rsa.public_key_openssh # Aquí se almacena la clave pública, que se crea automáticamente en el siguiente apartado 
}


# RSA Private key 
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


#Create local folder (para almacenar nuestra clave privada en local)
resource "local_file" "tf_key" {
  content  = tls_private_key.rsa.private_key_pem # La clave privada
  filename = "tfkey"
}


###################################################################################################################


#AMI for our EC2 instance 
data "aws_ami" "ubuntu" { #El bloque "data" le dice a Terraform no que CREE, sino que de alguna forma RECOLECTE información sobre algo
  most_recent = "true"
  
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

    owners = ["099720109477"] # Canonical
}


#EC2 instance 
resource "aws_instance" "server" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.large"
  key_name = aws_key_pair.tf_key.key_name
  subnet_id = aws_subnet.main.id
}

output "public_ip" {
  value = aws_eip.eip.public_ip #IPv4 public address (conectar con ssh)
}

###no conecta----> probar con otra key????