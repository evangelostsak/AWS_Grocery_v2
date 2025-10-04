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

resource "aws_route_table" "public" {
	vpc_id = aws_vpc.this.id
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.this.id
	}
	tags = merge(local.merged_tags, {
		Name = "${var.project_name}-${var.environment}-public-rt"
	})
}

resource "aws_route_table_association" "public" {
	for_each       = aws_subnet.public
	subnet_id      = each.value.id
	route_table_id = aws_route_table.public.id
}

