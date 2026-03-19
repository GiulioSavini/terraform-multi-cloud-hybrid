terraform {
  backend "s3" {
    bucket         = "hybrid-landing-zone-tfstate-dev"
    key            = "dev/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "hybrid-landing-zone-tflock-dev"
  }
}
