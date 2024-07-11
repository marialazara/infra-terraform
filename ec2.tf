#Instância
resource "aws_instance" "app_orbbi" {
  ami                    = "ami-06c68f701d8090592" #Amazon Linux 2023 AMI
  instance_type          = "t2.micro"
  associate_public_ip_address = yes
  vpc_security_group_ids = [aws_security_group.security_group.id]
  user_data              = file("./user_data.sh")
  key_name = "ssh-orbi-challenge"
  tags = {
    Name = "orbbi-app-instance"
  }
}

# Associação do Elastic IP
resource "aws_eip_association" "eip_orbbi_app" {
  instance_id   = aws_instance.app_orbbi.id
  allocation_id = data.aws_eip.eip_orbbi_app.id
}