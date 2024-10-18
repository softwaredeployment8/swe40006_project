provider "aws" {
  profile = "SWE40006"
  region  = "ap-southeast-2"
}

# Default Security Group Configuration
resource "aws_security_group" "my_security_group" {
  # Assuming the default VPC is used
  name        = "my-security-group"
  description = "Allow SSH, HTTP, and Grafana access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH access from any IP
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP access from any IP
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow Grafana access from any IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM Role for EC2 CloudWatch Monitoring
resource "aws_iam_role" "ec2_cloudwatch_role" {
  name = "ec2_cloudwatch_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# IAM Policy attached to the role
resource "aws_iam_role_policy" "ec2_cloudwatch_policy" {
  role   = aws_iam_role.ec2_cloudwatch_role.id
  policy = data.aws_iam_policy_document.ec2_cloudwatch_policy.json
}

# IAM Policy Document
data "aws_iam_policy_document" "ec2_cloudwatch_policy" {
  statement {
    actions   = ["cloudwatch:PutMetricData", "cloudwatch:GetMetricStatistics", "cloudwatch:ListMetrics"]
    resources = ["*"]
    effect    = "Allow"
  }
}

# IAM Instance Profile for Production Instance
resource "aws_iam_instance_profile" "ec2_cloudwatch_instance_profile" {
  name = "ec2_cloudwatch_instance_profile"
  role = aws_iam_role.ec2_cloudwatch_role.name
}

# Production EC2 Instance with Monitoring
resource "aws_instance" "production_instance" {
  ami                    = "ami-0f71013b2c8bd2c29"
  instance_type          = "t2.micro"
  key_name               = "mykey"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_cloudwatch_instance_profile.name
  subnet_id              = "subnet-0b1f3322b88146cb9"  

  tags = {
    Name        = "production-instance"
    Environment = "production"
  }
}

# Test EC2 Instance without Monitoring
resource "aws_instance" "test_instance" {
  ami                    = "ami-0f71013b2c8bd2c29"
  instance_type          = "t2.micro"
  key_name               = "mykey"
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  subnet_id              = "subnet-0b1f3322b88146cb9"  

  tags = {
    Name        = "test-instance"
    Environment = "test"
  }
}

# Grafana EC2 Instance
resource "aws_instance" "grafana" {
  ami                    = "ami-0f71013b2c8bd2c29"
  instance_type          = "t2.micro"
  key_name               = "mykey"
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  subnet_id              = "subnet-0b1f3322b88146cb9" 

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              # Set up swap space
              dd if=/dev/zero of=/swapfile bs=128M count=8
              chmod 600 /swapfile
              mkswap /swapfile
              swapon /swapfile
              # Setting up Grafana repository
              cat > /etc/yum.repos.d/grafana.repo <<EOL
              [grafana]
              name=Grafana
              baseurl=https://packages.grafana.com/oss/rpm
              repo_gpgcheck=1
              enabled=1
              gpgcheck=1
              gpgkey=https://packages.grafana.com/gpg.key
              sslverify=1
              sslcacert=/etc/pki/tls/certs/ca-bundle.crt
              EOL
              
              # Installing Grafana
              yum install grafana -y
              systemctl enable grafana-server
              systemctl start grafana-server
              EOF

  tags = {
    Name        = "Grafana"
    Environment = "monitoring"
  }
}