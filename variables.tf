variable "ami_id" {
  description = "AMI ID for the instance"
  type        = string
  default     = "ami-0c1c30571d2dae5c9"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = "tech501-yahya-keypair"
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "tech501-terraform-yahya-app"
}

variable "security_group_name" {
  description = "Name of the security group"
  type        = string
  default     = "tech257-yahya-tf-allow-port-22-3000-80"
}

variable "allowed_ports" {
  description = "List of allowed inbound ports"
  type        = list(number)
  default     = [22, 3000, 80]
}
