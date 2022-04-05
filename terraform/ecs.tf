# ECS Cluster
resource "aws_ecs_cluster" "production" {
  name = "production"
}


# Role for logging in task
resource "aws_iam_role" "ecs_task_assume_role" {
  name               = "server-excution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

# Generates json for policy document
data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Hardcode policy arn bc it's an Amazon Managed Policy
data "aws_iam_policy" "ecs_task_execution_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Attach policy to execution role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_assume_role.name
  policy_arn = data.aws_iam_policy.ecs_task_execution_role.arn
}

# Server service
resource "aws_ecs_service" "server" {
  name        = "server"
  cluster     = aws_ecs_cluster.production.id
  launch_type = "FARGATE"

  task_definition = aws_ecs_task_definition.server.arn
  desired_count   = 1
  force_new_deployment = true

  network_configuration {
    assign_public_ip = false

    security_groups = [
      aws_security_group.egress_all.id,
      aws_security_group.ingress_server_all.id,
    ]

    subnets = [
      aws_subnet.private_a.id,
      aws_subnet.private_b.id,
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.server.arn
    container_name   = "nginx"
    container_port   = 8080
  }
}


# Task definition for server
resource "aws_ecs_task_definition" "server" {
  family             = "server"
  execution_role_arn = aws_iam_role.ecs_task_assume_role.arn

  container_definitions = jsonencode([
    {
      name  = "nginx"
      image = var.server_image
      portMappings = [
        {
          containerPort = 8080
        }
      ]
      command = ["nginx", "-g", "daemon off;"]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = var.region
          awslogs-group         = "/ecs/server"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  # Minimum resources
  cpu    = 256
  memory = 512

  # Fargate compatible#
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
}

# Load balancer target
resource "aws_lb_target_group" "server" {
  name        = "server"
  vpc_id      = aws_vpc.production.id

  port     = 8080
  protocol = "HTTP"
  target_type = "ip"

  health_check {
    enabled = true
    path    = "/"
  }

  depends_on = [aws_alb.server]
}

# Load balancer
resource "aws_alb" "server" {
  name               = "server-lb"
  internal           = false
  load_balancer_type = "application"

  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id,
  ]

  security_groups = [
    aws_security_group.http.id,
    aws_security_group.egress_all.id,
  ]

  depends_on = [aws_internet_gateway.igw]
}


resource "aws_lb_listener" "server_http" {
  load_balancer_arn = aws_alb.server.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.server.arn
  }
}

# Print public url for this load balancer
output "server_url" {
  value = "http://${aws_alb.server.dns_name}"
}
