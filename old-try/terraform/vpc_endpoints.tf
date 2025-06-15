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