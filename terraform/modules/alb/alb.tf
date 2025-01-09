#Create internet-facing alb and internal alb
resource "aws_lb" "internet_alb" {
  name               = "dacn-internet-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.internet_alb_subnets

  enable_deletion_protection = var.enable_deletion_protection

  tags = {
    Name = "${var.alb_name}-internet-alb"
  }
}
resource "aws_lb" "internal_alb" {
  name               = "dacn-internal-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.internal_alb_subnets

  enable_deletion_protection = var.enable_deletion_protection

  tags = {
    Name = "${var.alb_name}-internal-alb"
  }
}



#Create target group for each service
resource "aws_lb_target_group" "front_end_target_group" {
  name        = "front-end"
  port        = 5173
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path     = "/"
    port     = var.health_check_port
    protocol = "HTTP"
    matcher  = var.matcher_code
  }
}
resource "aws_lb_target_group" "cart_service_target_group" {
  name        = "cart-service"
  port        = 3003
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path     = "/"
    port     = var.health_check_port
    protocol = "HTTP"
    matcher  = var.matcher_code
  }
}
resource "aws_lb_target_group" "product_service_target_group" {
  name        = "product-service"
  port        = 3002
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path     = "/"
    port     = var.health_check_port
    protocol = "HTTP"
    matcher  = var.matcher_code
  }
}
resource "aws_lb_target_group" "user_service_target_group" {
  name        = "user-service"
  port        = 3001
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path     = "/"
    port     = var.health_check_port
    protocol = "HTTP"
    matcher  = var.matcher_code
  }
}



#Create listener for each service
resource "aws_lb_listener" "front_end_listener" {
  load_balancer_arn = aws_lb.internet_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.front_end_target_group.arn
  }
}

resource "aws_lb_listener" "cart_service_listener" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = 3003
  protocol          = "HTTP"
  
  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "application/javascript"
      message_body = "console.log('Default action triggered');"
      status_code  = "200"
    }
  }
}
resource "aws_lb_listener_rule" "cs_rule" {
  listener_arn = aws_lb_listener.cart_service_listener.arn
  priority = 3

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.cart_service_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/api/cart*", "/api/cart/*"]
    }
  }
}

resource "aws_lb_listener" "product_service_listener" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = 3002
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "application/javascript"
      message_body = "console.log('Default action triggered');"
      status_code  = "200"
    }
  }
}
resource "aws_lb_listener_rule" "ps_rule" {
  listener_arn = aws_lb_listener.product_service_listener.arn
  priority = 2

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.product_service_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/api/products*", "/api/products/*", "/api/filter*"]
    }
  }
}

resource "aws_lb_listener" "user_service_listener" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = 3001
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "application/javascript"
      message_body = "console.log('Default action triggered');"
      status_code  = "200"
    }
  }
}
resource "aws_lb_listener_rule" "us_rule" {
  listener_arn = aws_lb_listener.user_service_listener.arn
  priority = 4

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.user_service_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/api/users*", "/api/users/*"]
    }
  }
}