# Create a VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "main-vpc"
  }
}

# Create public subnet for Jenkins VM
resource "aws_subnet" "jenkins_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.public_subnet_jenkins_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "jenkins-subnet"
  }
}

# Create public subnet for Kubernetes Cluster VM
resource "aws_subnet" "k8s_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.public_subnet_k8s_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "k8s-subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main-igw"
  }
}

# Create a Route Table for public subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associate the Route Table with Jenkins subnet
resource "aws_route_table_association" "jenkins_route_association" {
  subnet_id      = aws_subnet.jenkins_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Associate the Route Table with Kubernetes subnet
resource "aws_route_table_association" "k8s_route_association" {
  subnet_id      = aws_subnet.k8s_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Security Group for Jenkins
resource "aws_security_group" "jenkins_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow Jenkins access from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-sg"
  }
}

# Security Group for Kubernetes 
resource "aws_security_group" "k8s_sg" {
  vpc_id = aws_vpc.main_vpc.id

  # Allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Kubernetes API server access (port 6443)
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  # Allow Kubernetes NodePort range (30000-32767)
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-sg"
  }
}


# Launch EC2 instance for Jenkins
resource "aws_instance" "jenkins" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.jenkins_subnet.id
  security_groups = [aws_security_group.jenkins_sg.name]

  tags = {
    Name = "Jenkins-VM"
  }
}

# Launch EC2 instance for Kind Kubernetes Cluster
resource "aws_instance" "k8s_cluster" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.k8s_subnet.id
  security_groups = [aws_security_group.k8s_sg.name]

  tags = {
    Name = "K8s-VM"
  }
}
