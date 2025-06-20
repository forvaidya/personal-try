# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "denzopa-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "denzopa-cluster"
    project     = "denzopa"
    environment = "denzopa-dev"
  }
}

# ECS Cluster Capacity Provider
resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT", aws_ecs_capacity_provider.ec2.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.ec2.name
  }
}

# Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Launch Template for ECS EC2 instances
resource "aws_launch_template" "ecs" {
  name_prefix   = "denzopa-ecs-lt-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.medium"

  user_data = base64encode(<<-EOF
              #!/bin/bash
              # Update system and install required packages
              dnf update -y
              dnf install -y amazon-cloudwatch-agent amazon-ssm-agent curl docker jq

              # Install AWS CLI v2
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              dnf install -y unzip
              unzip awscliv2.zip
              ./aws/install

              # Install Docker Compose
              curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose

              # Start and enable services
              systemctl enable --now docker
              systemctl enable --now amazon-ssm-agent
              systemctl enable --now amazon-cloudwatch-agent

              # Add ec2-user to docker group
              usermod -aG docker ec2-user

              # Install and configure ECS agent
              dnf install -y ecs-init
              systemctl enable --now ecs
              echo ECS_CLUSTER=${aws_ecs_cluster.main.name} >> /etc/ecs/ecs.config

              # Ensure SSH is enabled and running
              systemctl enable --now sshd
              EOF
  )

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs.name
  }

  vpc_security_group_ids = [aws_security_group.ecs.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "denzopa-ecs-instance"
      project     = "denzopa"
      environment = "denzopa-dev"
    }
  }
}

# Auto Scaling Group for ECS
resource "aws_autoscaling_group" "ecs" {
  name                = "denzopa-ecs-asg"
  vpc_zone_identifier = [aws_subnet.private_1.id, aws_subnet.private_2.id, aws_subnet.private_3.id]
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "denzopa-ecs-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "project"
    value               = "denzopa"
    propagate_at_launch = true
  }

  tag {
    key                 = "environment"
    value               = "denzopa-dev"
    propagate_at_launch = true
  }
}

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution" {
  name = "denzopa-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    project     = "denzopa"
    environment = "denzopa-dev"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Definition
/*
resource "aws_ecs_task_definition" "app" {
  family                   = "denzopa-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  container_definitions = jsonencode([
    {
      name      = "nuxt-app-container"
      image     = var.container_image
      cpu       = 256
      memory    = 512
      essential = true

      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = "ap-south-1"
          awslogs-stream-prefix = "ecs"
        }
      }
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:3000/health || exit 1"]
        interval    = 60
        retries     = 3
        startPeriod = 60
        timeout     = 5
      }
    }
  ])

  tags = {
    Name        = "denzopa-task-definition"
    project     = "denzopa"
    environment = "denzopa-dev"
  }
}

# ECS Service
resource "aws_ecs_service" "app" {
  name            = "denzopa-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 3

  network_configuration {
    subnets          = [aws_subnet.private_1.id, aws_subnet.private_2.id, aws_subnet.private_3.id]
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "nuxt-app-container"
    container_port   = 3000
  }

  deployment_controller {
    type = "ECS"
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  tags = {
    Name        = "denzopa-service"
    project     = "denzopa"
    environment = "denzopa-dev"
  }
}
*/

# ECS Service Autoscaling
/*
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 12
  min_capacity       = 0
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy" {
  name               = "denzopa-ecs-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 70.0

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}
*/

# CloudWatch Log Group for ECS
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/denzopa"
  retention_in_days = 30

  tags = {
    Name        = "denzopa-ecs-logs"
    project     = "denzopa"
    environment = "denzopa-dev"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "aws logs delete-log-group --log-group-name /ecs/denzopa"
  }
}

# ECS Security Group
resource "aws_security_group" "ecs" {
  name        = "denzopa-ecs-sg"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "denzopa-ecs-sg"
    project     = "denzopa"
    environment = "denzopa-dev"
  }
}

# IAM Role for ECS
resource "aws_iam_role" "ecs" {
  name = "denzopa-ecs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    project     = "denzopa"
    environment = "denzopa-dev"
  }
}

# Attach required policies to ECS role
resource "aws_iam_role_policy_attachment" "ecs" {
  role       = aws_iam_role.ecs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ecs.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.ecs.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ecs" {
  name = "denzopa-ecs-profile"
  role = aws_iam_role.ecs.name
}

resource "aws_ecs_capacity_provider" "ec2" {
  name = "denzopa-ec2-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs.arn
    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}