################################
# Get my public IP automatically
################################
data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"
}

locals {
  my_ip_cidr = "${chomp(data.http.my_ip.response_body)}/32"
}


############################
# Bastion Key Pair
############################
resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion" {
  key_name   = "${var.project_name}-bastion-key"
  public_key = tls_private_key.bastion.public_key_openssh
}

resource "local_file" "bastion_pem" {
  content         = tls_private_key.bastion.private_key_pem
  filename        = "${path.module}/${var.project_name}-bastion.pem"
  file_permission = "0400"
}



############################
# Public Route Table
############################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}


############################
# Route Table Associations
############################
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public.id
}

############################
# Bastion EC2 Instance
############################
resource "aws_instance" "bastion" {
  ami                    = var.bastion_ami
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_a.id # Bastion은 보통 단일 AZ
  key_name               = aws_key_pair.bastion.key_name
  vpc_security_group_ids = [aws_security_group.bastion.id]

  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    sudo dnf -y install postgresql15
  EOF

  tags = {
    Name = "${var.project_name}-bastion"
  }
}
