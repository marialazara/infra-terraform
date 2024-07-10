#AWS Keypair:
resource "aws_key_pair" "keypair" {
  key_name   = "terraform-keypair"
  public_key = file("~/.ssh/id_rsa.pub")
}