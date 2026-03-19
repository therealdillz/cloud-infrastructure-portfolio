resource "aws_security_group" "ec2" {
    name        = "${var.project_name}-${var.environment}-ec2-sg"
    description = "Security group for EC2 instances"
    vpc_id      = var.vpc_id
    
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "SSH access"
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTP access"
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow all outbound traffic"
    }

    tags = {
        Name        = "${var.project_name}-${var.environment}-ec2-sg"
        Environment = var.environment
    }
}

resource "aws_key_pair" "ec2" {
    key_name   = "${var.project_name}-${var.environment}-key"
    public_key = var.public_key

    tags = {
        Name        = "${var.project_name}-${var.environment}-key"
        Environment = var.environment
    }
}

resource "aws_instance" "main" {
    ami           = var.ami_id
    instance_type = var.instance_type
    subnet_id     = var.public_subnet_ids[0]
    security_groups = [aws_security_group.ec2.id]
    key_name      = aws_key_pair.ec2.key_name
    associate_public_ip_address = true

    tags = {
        Name        = "${var.project_name}-${var.environment}-ec2-instance"
        Environment = var.environment
    }
}