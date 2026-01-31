provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "My_Server" {
  ami           = "ami-0b6c6ebed2801a5cb"
  instance_type = "t2.micro"

  tags = {
    Name = "Ubuntu Server"
  }
}