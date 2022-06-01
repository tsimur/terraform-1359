provider "aws" {
    region                  = "us-west-1"
    shared_credentials_files = ["~/.aws/credentials"]
    profile                 = "my_aws"
}

resource "aws_vpc" "web_vpc" {
  cidr_block        = "10.0.0.0/16"
  instance_tenancy  = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "WebVPC"
  }
}

resource "aws_internet_gateway" "gw-internet" {
  vpc_id = aws_vpc.web_vpc.id

  tags = {
    Name = "gw-internet"
  }
}

resource "aws_eip" "nat" {
    tags = {
    Name = "nat_ip"
  }
}

resource "aws_nat_gateway" "gw-nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnets[1].id

  tags = {
    Name = "gw-nat"
  }
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

resource "aws_route_table" "rtb_private_subnets" {
  vpc_id = aws_vpc.web_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gw-nat.id
  }

  tags = {
    Name = "rtb_private"
  }
}

resource "aws_route_table" "rtb_public_subnets" {
  vpc_id = aws_vpc.web_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw-internet.id
  }

  tags = {
    Name = "rtb_public"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private_subnets[count.index].id
  count          = 2
  route_table_id = aws_route_table.rtb_private_subnets.id
}


resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnets[count.index].id
  count          = 2
  route_table_id = aws_route_table.rtb_public_subnets.id
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.web_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDRN6+BlNKjcJYNXd5/IbyYjdLXV9WO31tORk6XxHy7nBoL1O9euSUcBfQQgyi6+vYLoPsWi0mV3kPOP6X394AKJY7/gqQI8YEo/3Y74Udih/jhQEoHipjyNZ0g/2/OuZb4v4mCieUGCR/UGu1hCRL7s0lkRs2weiWqMkNeo/D5Xejg90BVkpM8LbVIF4Cc29kHd3POp0zUjKFcT2BV5fKHbZwJpCzroc3rwXx1YflrGNThomgd4TLOz5NjYqImwec0L8VGNrjZ/3Ylqr5AAxrfg+vWk22DcK30kBWWgR3kh/2gUNVRQLl258FXu9se8U10gKS/gJ+EzYSt+pX7ymnt5LxUGUjCNGCksLKHNG/V3Zgtr+o/OStix7dEOr1t3h9rGgbf1q5xgQcyDHjduT5LGvwlk4xjeYw3pteWtww3XzNWUzW9zaOsIEwOKZ0QeIkfaDQNIp4sLhgwWlbzUpy/B1n4I1eZjOw3fK6ESvnYUP83VT27hffvXEftOKb9CfE= tmindarov@CMDB-78932"
}

resource "aws_instance" "website" {
  ami                     = "ami-0dc5e9ff792ec08e3"
  instance_type           = "t2.micro"
  key_name                = aws_key_pair.deployer.key_name
  vpc_security_group_ids  = [aws_security_group.allow_tls.id]
  subnet_id               = aws_subnet.private_subnets[count.index].id
  iam_instance_profile    = "AmazonSSMRoleForInstancesQuickSetup"
  count                   = 2

  user_data = file("sc.sh")

  tags = {
    Name = var.ec2_names[count.index]
  }
}

resource "aws_lb_target_group" "websites_target" {
  name     = "websites-target"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.web_vpc.id
}

resource "aws_lb_target_group_attachment" "web" {
  target_group_arn = aws_lb_target_group.websites_target.arn
  target_id        = aws_instance.website[count.index].id
  port             = 80
  count = 2
}

resource "aws_lb_listener" "WebSites" {
  load_balancer_arn = aws_lb.web_balancer.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.websites_target.arn
  }
}

resource "aws_lb" "web_balancer" {
  name               = "websites-nlb"
  internal           = false
  load_balancer_type = "network"
  # subnets            = [for subnet in aws_subnet.private_subnets : subnet.id]
  subnets            = [aws_subnet.public_subnets[0].id, aws_subnet.public_subnets[1].id]

  tags = {
    Environment = "two_websites"
  }
}