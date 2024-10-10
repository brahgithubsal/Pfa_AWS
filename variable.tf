variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_jenkins_cidr" {
  default = "10.0.1.0/24"
}

variable "public_subnet_k8s_cidr" {
  default = "10.0.2.0/24"
}

variable "instance_type" {
  default = "t2.medium"  # Adjust instance size as needed
}

variable "ami_id" {
  default = "ami-0c55b159cbfafe1fe"  
}
