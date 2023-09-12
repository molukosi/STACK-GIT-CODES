terraform{
    backend "s3"{
        bucket= "stackbuckstate-lekan"
        key = "terraform.tfsate"
            region="us-east-1"
            dynamodb_table="statelock-tf"
            }
 }