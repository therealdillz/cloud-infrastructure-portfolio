resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr

    tags = {
        Name        = "${var.project_name}-${var.environment}-vpc"
        Environment = var.environment
        Project     = var.project_name
    }
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name        = "${var.project_name}-${var.environment}-igw"
        Environment = var.environment

    }
}

resource "aws_subnet" "public" {
    count                  = length(var.public_subnet_cidrs)
    vpc_id                  = aws_vpc.main.id
    cidr_block              = var.public_subnet_cidrs[count.index]
    availability_zone       = var.availability_zones[count.index]
    map_public_ip_on_launch = true 

    tags = {
        Name        = "${var.project_name}-${var.environment}-public-${count.index + 1}"
        Environment = var.environment
    }
}

resource "aws_subnet" "private" {
    count            = length(var.private_subnet_cidrs)
    vpc_id            = aws_vpc.main.id
    cidr_block        = var.private_subnet_cidrs[count.index]
    availability_zone = var.availability_zones[count.index]

    tags = {
        Name        = "${var.project_name}-${var.environment}-private-${count.index + 1}"
        Environment = var.environment
    }
}

resource "aws_nat_gateway" "main" {
    count        = length(var.public_subnet_cidrs)
    allocation_id = aws_eipd.nat[count.index].id
    subnet_id     = aws_subnet.public[count.index].id

    tags = {
        Name        = "${var.project_name}-${var.environment}-nat-${count.index + 1}"
        Environment = var.environment
    }
}

resource "aws_eip" "nat" {
    count = length(var.public_subnet_cidrs)
    domain = "vpc"

    tags = {
        Name        = "${var.project_name}-${var.environment}-eip-nat-${count.index + 1}"
        Environment = var.environment
    }
}