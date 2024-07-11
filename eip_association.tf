#Associação com o IP Público do App Orbbi:
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.app-orbbi.id
  allocation_id = "eipalloc-0005e1dce2ab397b0"
}
