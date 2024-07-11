#Instância
resource "aws_instance" "app-orbbi" {
  ami                    = "ami-06c68f701d8090592" #Amazon Linux 2023 AMI
  instance_type          = "t2.small"
  vpc_security_group_ids = [aws_security_group.security_group.id]
  user_data              = file("./user_data.sh")
  key_name = "ssh-orbi-challenge"
  tags = {
    Name = "orbbi-app-instance"
  }
}
