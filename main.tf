resource "aws_instance" "app_instance" {
  # which AMI ID
  ami = "ami-0c1c30571d2dae5c9"

  # which type of instance
  instance_type = "t3.micro"

  # that we want a public ip
  associate_public_ip_address = true

  # name the service/instance
  tags = {
    Name = "tech501-terraform-yahya-app"
  }
}