resource "aws_lb" "web_lb" {
  name               = "finalexam-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = [aws_subnet.main_a.id, aws_subnet.main_b.id]

  tags = {
    Name = "finalexam-alb"
  }
}

resource "aws_lb_target_group" "web_tg" {
  name     = "finalexam-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200-399"
  }

  tags = {
    Name = "finalexam-tg"
  }
}

# Attach Production_Env1
resource "aws_lb_target_group_attachment" "prod1" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.prod_env1.id
  port             = 80
}

# Attach Production_Env2
resource "aws_lb_target_group_attachment" "prod2" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.prod_env2.id
  port             = 80
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}
