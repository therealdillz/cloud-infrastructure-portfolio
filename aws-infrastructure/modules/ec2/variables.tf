variable "project_name" {
    description = "Name of the project"
    type       = string
}

variable "environment" {
    description = "Environment name (dev or prod)"
    type       = string
}

variable "vpc_id" {
    description = "ID of the VPC"
    type      = string
}

variable "public_subnet_ids" {
    description = "IDs of the public subnets"
    type      = list(string)
}

variable "instance_type" {
    description = "EC2 instance type"
    type       = string
    default    = "t2.micro"
}

variable "ami_id" {
    description = "AMI ID for the EC2 instance"
    type       = string
}

variable "public_key" {
    description = "Public key for SSH access"
    type       = string
}
