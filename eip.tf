resource "aws_eip" "app-orbbi-eip" {
  vpc = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.app-orbbi.id
  allocation_id = aws_eip.app-orbbi-eip.id
}
