resource "aws_cloudwatch_log_group" "front_end_log_group" {
  name = "/ecs/front-end-service-log"
}
resource "aws_cloudwatch_log_group" "product_service_log_group" {
  name = "/ecs/product-service-log"
}
resource "aws_cloudwatch_log_group" "cart_service_log_group" {
  name = "/ecs/cart-service-log"
}
resource "aws_cloudwatch_log_group" "user_service_log_group" {
  name = "/ecs/user-service-log"
}

resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
}


#Create ECS Task Definiton
resource "aws_ecs_task_definition" "front_end_task" {
  family = "front-end"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  task_role_arn = "arn:aws:iam::329599660036:role/ecsTaskRole"
  execution_role_arn = "arn:aws:iam::329599660036:role/ecsTaskExecutionRole"
  container_definitions = jsonencode([
    {
      name      = "front-end"
      image     = "329599660036.dkr.ecr.us-east-1.amazonaws.com/lamlt-sonvt:front-end"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 5173
          hostPort      = 5173
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/front-end-service-log"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "user"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "product_service_task" {
  family = "product"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  task_role_arn = "arn:aws:iam::329599660036:role/ecsTaskRole"
  execution_role_arn = "arn:aws:iam::329599660036:role/ecsTaskExecutionRole"
  container_definitions = jsonencode([
    {
      name      = "product"
      image     = "329599660036.dkr.ecr.us-east-1.amazonaws.com/lamlt-sonvt:product"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 3002
          hostPort      = 3002
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/product-service-log"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "user"
        }
      }
    }
  ])
}
resource "aws_ecs_task_definition" "cart_service_task" {
  family = "cart"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  task_role_arn = "arn:aws:iam::329599660036:role/ecsTaskRole"
  execution_role_arn = "arn:aws:iam::329599660036:role/ecsTaskExecutionRole"
  container_definitions = jsonencode([
    {
      name      = "cart"
      image     = "329599660036.dkr.ecr.us-east-1.amazonaws.com/lamlt-sonvt:cart"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 3003  
          hostPort      = 3003
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/cart-service-log"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "user"
        }
      }
    }
  ])
}
resource "aws_ecs_task_definition" "user_service_task" {
  family = "user"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  task_role_arn = "arn:aws:iam::329599660036:role/ecsTaskRole"
  execution_role_arn = "arn:aws:iam::329599660036:role/ecsTaskExecutionRole"
  container_definitions = jsonencode([
    {
      name      = "user"
      image     = "329599660036.dkr.ecr.us-east-1.amazonaws.com/lamlt-sonvt:user"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 3001
          hostPort      = 3001
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/user-service-log"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "user"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "front-end" {
  name            = "front-end"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.front_end_task.id
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_id
    security_groups = var.security_group_id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_fe_arn
    container_name   = "front-end"
    container_port   = 5173
  }

  desired_count = 1
}
resource "aws_ecs_service" "cart" {
  name            = "cart"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.cart_service_task.id
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_id
    security_groups = var.security_group_id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_cs_arn
    container_name   = "cart"
    container_port   = 3003
  }

  desired_count = 1
}
resource "aws_ecs_service" "product" {
  name            = "product"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.product_service_task.id
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_id
    security_groups = var.security_group_id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_ps_arn
    container_name   = "product"
    container_port   = 3002
  }

  desired_count = 1
}
resource "aws_ecs_service" "user" {
  name            = "user"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.user_service_task.id
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_id
    security_groups = var.security_group_id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_us_arn
    container_name   = "user"
    container_port   = 3001
  }

  desired_count = 1
}