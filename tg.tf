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
