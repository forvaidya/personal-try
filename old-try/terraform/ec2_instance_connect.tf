# EC2 Instance Connect Endpoint
resource "aws_ec2_instance_connect_endpoint" "main" {
  subnet_id = aws_subnet.public_1.id
  preserve_client_ip = true
  security_group_ids = [aws_security_group.instance_connect.id]

  tags = {
    Name        = "denzopa-ec2-instance-connect-endpoint"
    project     = "denzopa"
    environment = "denzopa-dev"
  }
}

# Security Group for EC2 Instance Connect Endpoint
resource "aws_security_group" "instance_connect" {
  name        = "denzopa-instance-connect-sg"
  description = "Security group for EC2 Instance Connect Endpoint"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "denzopa-instance-connect-sg"
    project     = "denzopa"
    environment = "denzopa-dev"
  }
} 