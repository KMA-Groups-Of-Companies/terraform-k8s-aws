provider "aws" {
  region = var.aws_region
}

# 1. Networking Setup (VPC, Subnet, IGW, Route Table)
resource "aws_vpc" "k8s_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.cluster_name}-vpc"
  }
}

resource "aws_subnet" "k8s_subnet1" {
  vpc_id     = aws_vpc.k8s_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.cluster_name}-subnet"
  }
}

resource "aws_subnet" "k8s_subnet2" {
  vpc_id     = aws_vpc.k8s_vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.cluster_name}-subnet"
  }
}

resource "aws_internet_gateway" "k8s_igw" {
  vpc_id = aws_vpc.k8s_vpc.id
  tags = {
    Name = "${var.cluster_name}-igw"
  }
}

resource "aws_route_table" "k8s_rt" {
  vpc_id = aws_vpc.k8s_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s_igw.id
  }
  tags = {
    Name = "${var.cluster_name}-rt"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.k8s_subnet.id
  route_table_id = aws_route_table.k8s_rt.id
}

# 2. Security Group
resource "aws_security_group" "k8s_sg" {
  name        = "${var.cluster_name}-sg"
  description = "Allow traffic for the K8s cluster"
  vpc_id      = aws_vpc.k8s_vpc.id

  # Allow SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: For learning only. Restrict to your IP in production.
  }

  # Allow K8s API server access
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: For learning only.
  }

  # Allow all internal traffic between nodes
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }
  
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. Installation Script (run on every node)
data "template_file" "install_k8s" {
  template = file("${path.module}/install_k8s.sh")
}

# 4. Control Plane (Master) Node
resource "aws_instance" "control_plane" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.k8s_subnet1.id
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  
  user_data = data.template_file.install_k8s.rendered
  
  tags = {
    Name = "${var.cluster_name}-control-plane"
  }
}

# 5. Worker Nodes
resource "aws_instance" "worker_nodes" {
  count         = 2 # Create 2 worker nodes
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.k8s_subnet.id
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]

  user_data = data.template_file.install_k8s.rendered

  tags = {
    Name = "${var.cluster_name}-worker-${count.index}"
  }
}