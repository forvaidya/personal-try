# CloudWatch Log Group for EC2 Instance Connect
resource "aws_cloudwatch_log_group" "instance_connect" {
  name              = "/aws/ec2-instance-connect/denzopa"
  retention_in_days = 30

  tags = {
    Name        = "denzopa-instance-connect-logs"
    project     = "denzopa"
    environment = "denzopa-dev"
  }
}

# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc-flow-logs/denzopa"
  retention_in_days = 30

  tags = {
    Name        = "denzopa-vpc-flow-logs"
    project     = "denzopa"
    environment = "denzopa-dev"
  }
}

# IAM Role for VPC Flow Logs
resource "aws_iam_role" "vpc_flow_logs" {
  name = "denzopa-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    project     = "denzopa"
    environment = "denzopa-dev"
  }
}

# IAM Role Policy for VPC Flow Logs
resource "aws_iam_role_policy" "vpc_flow_logs" {
  name = "denzopa-vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# VPC Flow Logs
resource "aws_flow_log" "vpc" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id

  tags = {
    Name        = "denzopa-vpc-flow-logs"
    project     = "denzopa"
    environment = "denzopa-dev"
  }
}
