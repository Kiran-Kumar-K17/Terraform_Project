provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "production-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "production-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.production-vpc.id

  tags = {
    Name = "production-vpc-ig"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id = aws_vpc.production-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.production-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "public_rt"
  }
}

resource "aws_route_table_association" "public_rt_asso" {
  subnet_id = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "sg" {
  name = "allow_ssh_http"
  description = "Allow ssh http inbound traffic"
  vpc_id = aws_vpc.production-vpc.id

  ingress {
    description = "SSH from VPC"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    description = "HTTP from VPC"
    from_port = 80
    to_port = 80
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
    Name = "allow_ssh_http"
  }
}


resource "aws_instance" "web-server" {
  ami           = "ami-0b6c6ebed2801a5cb"
  instance_type = "t2.micro"
  key_name = "Nitrox"
  subnet_id = aws_subnet.public-subnet.id
  security_groups = [aws_security_group.sg.id]


    user_data = <<-EOF
    #!/bin/bash
    echo "Checking for Updates"
    sudo apt update -y
    echo "Installing Apache2"
    sudo apt install apache2 -y
    sudo systemctl start apache2
    sudo systemctl enable apache2
    echo "Completed Installing Apache2"
    echo "<h1>Terraform Web Server is LIVE 🚀</h1>" > /var/www/html/index.html
    EOF


  tags = {
    Name = "web_instance"
  }
}

output "web_instance_public_ip"  {
    value = aws_instance.web-server.public_ip
}