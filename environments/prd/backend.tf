terraform {
  backend "s3" {
    bucket         = "hybrid-landing-zone-tfstate-prd"
    key            = "prd/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "hybrid-landing-zone-tflock-prd"
  }
}
