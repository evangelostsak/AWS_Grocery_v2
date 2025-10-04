############################################
# VPC MODULE - Networking Components
############################################

resource "aws_vpc" "this" {
	cidr_block           = var.vpc_cidr
	enable_dns_support   = true
	enable_dns_hostnames = true
	tags = merge(local.merged_tags, {
		Name = "${var.project_name}-${var.environment}-vpc"
	})
}

resource "aws_internet_gateway" "this" {
	vpc_id = aws_vpc.this.id
	tags = merge(local.merged_tags, {
		Name = "${var.project_name}-${var.environment}-igw"
	})
}

# Public Subnets
resource "aws_subnet" "public" {
	for_each = { for idx, cidr in var.public_subnet_cidrs : idx => {
		cidr = cidr
		az   = var.availability_zones[idx]
	} }
	vpc_id                  = aws_vpc.this.id
	cidr_block              = each.value.cidr
	availability_zone       = each.value.az
	map_public_ip_on_launch = true
	tags = merge(local.merged_tags, {
		Name = "${var.project_name}-${var.environment}-public-${each.key}"
		Tier = "public"
	})
}

# Private Subnets
resource "aws_subnet" "private" {
	for_each = { for idx, cidr in var.private_subnet_cidrs : idx => {
		cidr = cidr
		az   = var.availability_zones[idx]
	} }
	vpc_id            = aws_vpc.this.id
	cidr_block        = each.value.cidr
	availability_zone = each.value.az
	tags = merge(local.merged_tags, {
		Name = "${var.project_name}-${var.environment}-private-${each.key}"
		Tier = "private"
	})
}

# Public Route Table
resource "aws_route_table" "public_rt" {
	vpc_id = aws_vpc.this.id
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.this.id
	}
	tags = merge(local.merged_tags, {
		Name = "${var.project_name}-${var.environment}-public-rt"
	})
}

# Public Route Table Associations
resource "aws_route_table_association" "public" {
	for_each       = aws_subnet.public
	subnet_id      = each.value.id
	route_table_id = aws_route_table.public.id
}

# Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.merged_tags, {
    Name = "${var.project_name}-${var.environment}-private-rt"
  })
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

# DB Subnet Group for RDS
resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = merge(local.merged_tags, {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  })
}

# S3 VPC Gateway Endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [aws_route_table.private_rt.id]

  tags = merge(local.merged_tags, {
    Name = "${var.project_name}-${var.environment}-s3-endpoint"
  })
}