#vpc
resource "aws_vpc" "this" {
  
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags, {
        Name = "${var.tags["stack_name"]}-vpc"
    }
  )
}

#internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

    tags = merge(
    var.tags, {
        Name = "${var.tags["stack_name"]}-igw"
    }
  )
}

#public subnets
resource "aws_subnet" "public" {
  
  for_each = var.public_subnet_cidrs

  vpc_id = aws_vpc.this.id
  cidr_block = each.value
  availability_zone = each.key  
  map_public_ip_on_launch = true
  

  tags = merge(var.tags, {
    Name = "${var.tags["stack_name"]}-public-${each.key}"
    "kubernetes.io/role/elb" = "1"
  })

}

#private subnets
resource "aws_subnet" "private" {
  
  for_each = var.private_subnet_cidrs

  vpc_id = aws_vpc.this.id
  cidr_block = each.value
  availability_zone = each.key
  map_public_ip_on_launch = false
  

  tags = merge(var.tags, {
    Name = "${var.tags["stack_name"]}-private-${each.key}"
    "kubernetes.io/role/internal-elb" = "1"
  })
  
}


#nat eip
resource "aws_eip" "nat" {
  for_each = aws_subnet.public
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.tags["stack_name"]}-nat-eip-${each.key}"
  })
}


#nat gateway
resource "aws_nat_gateway" "nat" {
  for_each = aws_subnet.public
  
  subnet_id = each.value.id
  allocation_id = aws_eip.nat[each.key].id
  

  tags = merge(var.tags, {
    Name = "${var.tags["stack_name"]}-nat-${each.key}"
  })
}

#public route table

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = merge(var.tags, {
    Name = "${var.tags["stack_name"]}-public-rt"
  })
}

resource "aws_route" "public_inet" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public
  subnet_id = each.value.id
  route_table_id = aws_route_table.public.id
}

# private route table

resource "aws_route_table" "private" {
  for_each = aws_subnet.private
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.tags["stack_name"]}-private-rt-${each.key}"
  })
}

resource "aws_route" "private_nat" {
  for_each = aws_route_table.private

  route_table_id = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat[each.key].id
}

resource "aws_route_table_association" "private_assoc" {
  for_each = aws_subnet.private
  subnet_id = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}