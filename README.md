# AWS Infrastructure with Terraform

This Terraform configuration provisions an AWS EC2 instance along with a security group.

## Resources Created

1. **EC2 Instance (`aws_instance.app_instance`)**

   - Uses an AMI specified by `var.ami_id`.
   - Instance type defined by `var.instance_type`.
   - Automatically associates a public IP.
   - Uses an SSH key pair specified by `var.key_name`.
   - Assigned to a security group (`aws_security_group.tech257_sg`).
   - Tagged with a name defined by `var.instance_name`.

2. **Security Group (`aws_security_group.tech257_sg`)**
   - Named according to `var.security_group_name`.
   - Allows inbound traffic on ports defined in `var.allowed_ports`.
   - Allows all outbound traffic.

## Usage

Ensure that the required variables (AMI ID, instance type, key name, and security group name) are properly defined before applying this configuration using:

```sh
terraform init
terraform apply
```
