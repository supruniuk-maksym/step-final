# To create the S3 bucket manually, run this:
# aws s3api create-bucket \
#   --bucket danit-devops-tf-state-max \
#   --region ca-central-1 \
#   --create-bucket-configuration LocationConstraint=ca-central-1 \
#   --profile aws-cli-user

# To create the DynamoDB table for state locking, run this:
# aws dynamodb create-table \
#   --table-name lock-tf-eks \
#   --attribute-definitions AttributeName=LockID,AttributeType=S \
#   --key-schema AttributeName=LockID,KeyType=HASH \
#   --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
#   --region ca-central-1 \
#   --profile aws-cli-user

terraform {
  backend "s3" {
    bucket         = "danit-devops-tf-state-max"
    key            = "eks/terraform.tfstate"
    region         = "ca-central-1"
    profile        = "aws-cli-user"
    dynamodb_table = "lock-tf-eks"
    encrypt        = true
  }

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.6.0, < 3.0.0"
    }
  }
}
