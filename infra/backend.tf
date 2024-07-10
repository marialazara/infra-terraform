terraform {
  backend "s3" {
    bucket         = var.TF_STATE_BUCKET
    key            = var.TF_STATE_KEY
    region         = var.AWS_REGION
    dynamodb_table = var.DYNAMODB_TABLE
    encrypt        = true
  }
}
