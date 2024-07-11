#Instância
resource "aws_instance" "app-orbbi" {
  ami                    = "ami-06c68f701d8090592" #Amazon Linux 2023 AMI
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.security_group.id]
  user_data              = file("./user_data.sh")
  key_name               = aws_key_pair.keypair.key_name

  tags = {
    Name = "orbi-app-instance"
  }
}