terraform {
  backend "s3" {
    bucket         = "marialazara-us-east-1-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "marialazara-us-east-1-terraform-lock"
  }
}