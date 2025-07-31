# Application Load Balancer Configuration
# Owner: Touqeer Hussain

# Application Load Balancer
resource "aws_lb" "web_alb" {
  name               = "${var.environment}-alb-web"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public_subnets[*].id

  enable_deletion_protection = false

  # Access logs to S3
  access_logs {
    bucket  = aws_s3_bucket.logs.id
    prefix  = "alb-access-logs"
    enabled = true
  }

  tags = {
    Name        = "${var.environment}-alb-web"
    Environment = var.environment
  }

  depends_on = [aws_s3_bucket_policy.logs_policy]
}

# Target Group for EC2 instances
resource "aws_lb_target_group" "web_tg" {
  name     = "${var.environment}-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.practice_vpc.id

  # Health check configuration
  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  # Stickiness configuration
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = false
  }

  tags = {
    Name = "${var.environment}-web-tg"
  }
}

# HTTP Listener
resource "aws_lb_listener" "web_http" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }

  tags = {
    Name = "${var.environment}-alb-listener-http"
  }
}

# HTTPS Listener (optional - requires SSL certificate)
# Uncomment and configure if you have an SSL certificate
/*
resource "aws_lb_listener" "web_https" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.web_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }

  tags = {
    Name = "${var.environment}-alb-listener-https"
  }
}

# SSL Certificate (optional)
resource "aws_acm_certificate" "web_cert" {
  domain_name       = "yourdomain.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.environment}-web-cert"
  }
}
*/