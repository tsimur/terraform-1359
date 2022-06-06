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