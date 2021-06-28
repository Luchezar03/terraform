terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

resource "aws_default_subnet" "subnet_1" {
  availability_zone = "eu-central-1a"

  tags = {
    Name = "Default subnet for eu-central-1a"
  }
}
resource "aws_default_subnet" "subnet_2" {
  availability_zone = "eu-central-1b"

  tags = {
    Name = "Default subnet for eu-central-1b"
  }
}
resource "aws_security_group" "pyshuk-sg" {
  name        = "pyshuk-sg"
  description = "Allow traffic"

ingress {
    description      = "HTTP traffic"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  tags = {
    Name = "pyshuk-sg"
  }
}

provider "aws" {
  region  = "eu-central-1"
}

resource "aws_instance" "pyshuk-vm1" {
  ami           = "ami-0b1deee75235aa4bb"
  instance_type = "t2.micro"
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello VM1" > index.html
              nohup busybox httpd -f -p 80 &
              EOF
  vpc_security_group_ids = [aws_security_group.pyshuk-sg.id]
  availability_zone = "eu-central-1a"
  
  tags = {
    Name = "VM1"
  }
}

resource "aws_instance" "pyshuk-vm2" {
  ami           = "ami-0b1deee75235aa4bb"
  instance_type = "t2.micro"
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello VM2" > index.html
              nohup busybox httpd -f -p 80 &
              EOF
  vpc_security_group_ids = [aws_security_group.pyshuk-sg.id]
  availability_zone = "eu-central-1b"
  
  tags = {
    Name = "VM2"
  }
}
resource "aws_lb" "pyshuk-lb" {
  name                             = "pyshuk-lb"
  internal                         = false
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true
  
  subnet_mapping {
    subnet_id     = aws_default_subnet.subnet_1.id
  }

  subnet_mapping {
    subnet_id     = aws_default_subnet.subnet_2.id
  }
}

resource "aws_lb_target_group_attachment" "add-vm1" {
  target_group_arn = aws_lb_target_group.pyshuk-tg.arn
  target_id        = aws_instance.pyshuk-vm1.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "add-vm2" {
  target_group_arn = aws_lb_target_group.pyshuk-tg.arn
  target_id        = aws_instance.pyshuk-vm2.id
  port             = 80
}

resource "aws_lb_target_group" "pyshuk-tg" {
  name     = "pyshuk-tg"
  port     = 80
  protocol = "TCP"
  vpc_id      = aws_default_vpc.default_vpc.id
}

resource "aws_default_vpc" "default_vpc" {
  tags = {
    Name = "Default VPC"
  }
}
# Create listener
resource "aws_lb_listener" "lb" {
  
  load_balancer_arn = aws_lb.pyshuk-lb.arn
  port              = "80"
  protocol          = "TCP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pyshuk-tg.arn
  }
}
