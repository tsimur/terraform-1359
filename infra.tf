provider "aws" {
    region                  = "us-east-1"
    shared_credentials_files = ["~/.aws/credentials"]
    profile                 = "my_aws"
}

resource "aws_vpc" "web_vpc" {
  cidr_block        = "10.0.0.0/16"
  instance_tenancy  = "default"
  tags = {
    Name = "WebVPC"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.web_vpc.id

  tags = {
    Name = "web_main"
  }
}

resource "aws_lb_target_group" "websites_target" {
  name     = "websites-target"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.web_vpc.id
}

resource "aws_route" "route_rule" {
  route_table_id            = aws_vpc.web_vpc.main_route_table_id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.gw.id
}

resource "aws_subnet" "private_subnets" {
  vpc_id                = aws_vpc.web_vpc.id
  cidr_block            = var.private_subnates_ips[count.index]
  availability_zone_id  = var.av_zone_ids[count.index]
  count = 2
  tags = {
    Name = var.private_subnates_names[count.index]
  }
}

resource "aws_subnet" "public_subnets" {
  vpc_id                = aws_vpc.web_vpc.id
  cidr_block            = var.public_subnates_ips[count.index]
  availability_zone_id  = var.av_zone_ids[count.index]
  count = 2
  tags = {
    Name = var.public_subnates_names[count.index]
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.web_vpc.id

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all"
  }
}

resource "aws_instance" "website" {
  ami           = "ami-09d56f8956ab235b3"
  instance_type = "t2.micro"
  
  vpc_security_group_ids  = [aws_security_group.allow_tls.id]
  subnet_id               = aws_subnet.private_subnets[count.index].id

  count = 2

  tags = {
    Name = var.ec2_names[count.index]
  }
}

resource "aws_lb_target_group_attachment" "web" {
  target_group_arn = aws_lb_target_group.websites_target.arn
  target_id        = aws_instance.website[count.index].id
  port             = 80
  count = 2
}

resource "aws_lb" "test" {
  name               = "websites_nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}