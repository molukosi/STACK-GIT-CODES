provider "aws" {
  region     = var.AWS_REGION
  access_key = locals.db_creds.AWS_ACCESS_KEY
  secret_key = locals.db_creds.AWS_SECRET_KEY

  assume_role {
    role_arn = "arn:aws:iam::541478845275:role/Engineer"
  }
}