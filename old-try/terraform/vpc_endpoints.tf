# Security Group for VPC Endpoints
resource "aws_security_group" "vpc_endpoints" {
  name        = "denzopa-vpc-endpoints-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "denzopa-vpc-endpoints-sg"
    project     = "denzopa"
    environment = "denzopa-dev"
  }
}

# VPC Endpoint Policy
resource "aws_vpc_endpoint_policy" "ec2_instance_connect" {
  vpc_endpoint_id = aws_vpc_endpoint.ec2_instance_connect.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = [
          "ec2-instance-connect:SendSSHPublicKey",
          "ec2-instance-connect:OpenTunnel"
        ]
        Resource = "*"
      }
    ]
  })
} 