terraform {
  backend "s3" {
    bucket         = "danit-devops-tf-state-max"
    key            = "argocd/eso.tfstate" # 
    region         = "ca-central-1"
    profile        = "aws-cli-user"
    dynamodb_table = "lock-tf-eks"
    encrypt        = true
  }
}