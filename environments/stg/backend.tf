terraform {
  backend "s3" {
    bucket         = "hybrid-landing-zone-tfstate-stg"
    key            = "stg/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "hybrid-landing-zone-tflock-stg"
  }
}
