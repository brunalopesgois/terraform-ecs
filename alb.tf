#in this template we are creating aws application laadbalancer and target group and alb http listener

resource "aws_alb" "unionaudio-backend-alb" {
  name            = "union-audio-backend-lb"
  subnets         = aws_subnet.unionaudio-backend-public.*.id
  security_groups = [aws_security_group.alb-sg.id]
}

resource "aws_alb_target_group" "unionaudio-backend-tg" {
  name        = "union-audio-backend-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.unionaudio-backend-vpc.id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    protocol            = "HTTP"
    matcher             = "200"
    path                = var.health_check_path
    interval            = 30
  }
}

#redirecting all incomming traffic from ALB to the target group
resource "aws_alb_listener" "unionaudio-backend-alb-listener" {
  load_balancer_arn = aws_alb.unionaudio-backend-alb.id
  port              = var.app_port
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
  #enable above 2 if you are using HTTPS listner and change protocal from HTTP to HTTPS
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.unionaudio-backend-tg.arn
  }
}
