###  TARGET GROUP FOR LOAD BALANCER ###

resource "aws_lb_target_group" "target_group" {
  name        = "LB-TargetGroup"
  port        = 80
  target_type = "instance"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.nginx_vpc.id
}

### ATTACHING TARGET GROUP TO EC2S ###

resource "aws_alb_target_group_attachment" "targ_group_attach" {
  count            = length(aws_instance.ec2.*.id) == 3 ? 3 : 0
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = element(aws_instance.ec2.*.id, count.index)
}

### APP LOAD BALANCER ###

resource "aws_lb" "app_load_balancer" {
  name               = "AppLoadBalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.security_group.id, ]
  subnets            = aws_subnet.public_subnet.*.id

}


### LOAD BALANCER LISTENER ###

resource "aws_lb_listener" "eavesdropper" {
  load_balancer_arn = aws_lb.app_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}



### RULES FOR LISTENER ###

resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.eavesdropper.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn

  }

  condition {
    path_pattern {
      values = ["/var/www/html/index.html"]
    }
  }
}
