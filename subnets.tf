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