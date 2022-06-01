provider "aws" {
    region                  = "us-west-1"
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

resource "aws_internet_gateway" "gw-internet" {
  vpc_id = aws_vpc.web_vpc.id

  tags = {
    Name = "gw-internet"
  }
}

resource "aws_eip" "nat" {
  depends_on = [aws_internet_gateway.gw-internet]
}

resource "aws_nat_gateway" "gw-nat" {
  # depends_on = [aws_internet_gateway.gw-internet]
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.private_subnets[1].id

  tags = {
    Name = "gw-nat"
  }
}

resource "aws_lb_target_group" "websites_target" {
  name     = "websites-target"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.web_vpc.id
}

# resource "aws_route" "route_rule" {
#   route_table_id            = aws_vpc.web_vpc.main_route_table_id
#   destination_cidr_block    = "0.0.0.0/0"
#   gateway_id                = aws_internet_gateway.gw-internet.id
# }

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
    gateway_id = aws_internet_gateway.gw-internet.id
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
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all"
  }
}

resource "aws_instance" "website" {
  ami                     = "ami-0dc5e9ff792ec08e3"
  instance_type           = "t2.micro"
  
  vpc_security_group_ids  = [aws_security_group.allow_tls.id]
  subnet_id               = aws_subnet.public_subnets[count.index].id

  iam_instance_profile    = "AmazonSSMRoleForInstancesQuickSetup"

  count                   = 2

  tags = {
    Name = var.ec2_names[count.index]
  }
}

resource "aws_lb" "web_balancer" {
  name               = "websites-nlb"
  internal           = false
  load_balancer_type = "network"
  # subnets            = [for subnet in aws_subnet.private_subnets : subnet.id]
  subnets            = [aws_subnet.private_subnets[0].id, aws_subnet.private_subnets[1].id]

  enable_deletion_protection = true

  tags = {
    Environment = "two_websites"
  }
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