# Certificate
resource "aws_acm_certificate" "cert" {
  domain_name       = "lb.trimble.in"
  validation_method = "DNS"
}

# Load Balancer Resource
resource "aws_lb" "loadbal" {
  name               = "mainlb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elbsg.id]
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]
}


# Target Group
resource "aws_lb_target_group" "lbtg" {
  name        = "lbtg"
  port        = 80
  target_type = "instance"
  vpc_id      = aws_vpc.trimble_main.id
  protocol    = "HTTP"
  health_check {
    enabled  = true
    interval = 10
    path     = "/login"
    port     = 8080
    protocol = "HTTP"
    matcher  = "200-299"
  }
}

# LB Listener
resource "aws_lb_listener" "lblistener" {
  load_balancer_arn = aws_lb.loadbal.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.cert.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lbtg.arn
  }
}

# Launch Configuration
resource "aws_launch_configuration" "weblc" {
  name_prefix = "web-"
  image_id = "ami-a0cfeed8" 
  instance_type = "t2.micro"

  security_groups = [aws_security_group.webtier.id]

  user_data = <<USER_DATA
  #!/bin/bash
  yum update
  yum -y install nginx
  echo "Hello Trimble !" > /usr/share/nginx/html/index.html
  chkconfig nginx on
  service nginx start
  USER_DATA

  lifecycle {
    create_before_destroy = true
  }
}

# AutoScaling Group
resource "aws_autoscaling_group" "webasg" {
  name = "trimbleapp-asg"

  min_size             = 1
  desired_capacity     = 2
  max_size             = 3
  
  launch_configuration = aws_launch_configuration.web.name
  vpc_zone_identifier  = [aws_subnet.private1.id,aws_subnet.private2.id]

  health_check_type    = "ELB"
  health_check_grace_period = 500

  tag {
    key                 = "Name"
    value               = "app"
    propagate_at_launch = true
  }

}

# Target Group & ASG Attachement
resource "aws_autoscaling_attachment" "asgattach" {
  alb_target_group_arn   = aws_lb_target_group.lbtg.arn
  autoscaling_group_name = aws_autoscaling_group.webasg.id
}
