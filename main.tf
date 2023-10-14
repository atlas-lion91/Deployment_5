provider "aws" {
  access_key = ""
  secret_key = ""
  region = "us-east-1"
  #profile = "Admin"
}

resource "aws_vpc" "dep5_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "dep5_subnet_1" {
  vpc_id     = aws_vpc.dep5_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a" # 
  map_public_ip_on_launch = true
}

resource "aws_subnet" "dep5_subnet_2" {
  vpc_id     = aws_vpc.dep5_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b" 
  map_public_ip_on_launch = true
}

resource "aws_security_group" "dep5_sg" {
  vpc_id = aws_vpc.dep5_vpc.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "dep5_instance_1" {
  ami           = "ami-08c40ec9ead489470" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.dep5_subnet_1.id
  security_groups = [aws_security_group.dep5_sg.id]
  key_name      = "var.key_name"

 user_data = "${file("build.sh")}"

  tags = {
    Name = "Dep5_Instance_1"
  }
}

resource "aws_instance" "Dep5_instance_2" {
  ami           = "ami-08c40ec9ead489470" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.dep5_subnet_2.id
  security_groups = [aws_security_group.dep5_sg.id]
  key_name      = "var.key_name"

 user_data = "${file("pyinstall.sh")}"
  tags = {
    Name = "Dep5_Instance 2"
  }
}

resource "aws_internet_gateway" "dep5_gw" {
  vpc_id = aws_vpc.dep5_vpc.id

  tags = {
    Name = "dep5_gw"
  }
}


resource "aws_route_table" "dep5_rt" {
  vpc_id = aws_vpc.dep5_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dep5_gw.id
  }
}

resource "aws_default_route_table" "example" {
  default_route_table_id = aws_vpc.dep5_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dep5_gw.id
  }
}


resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.dep5_subnet_1.id
  route_table_id = aws_route_table.dep5_rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.dep5_subnet_2.id
  route_table_id = aws_route_table.dep5_rt.id
}
