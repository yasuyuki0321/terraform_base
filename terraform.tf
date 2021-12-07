terraform {
  required_version = "~> 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }

  /*
  backend s3は検証時はコメントアウトしておくこと。
  Terraformで作成したリソースの状態を複数のメンバーで共有するためにtfstateファイルの保管先を指定する。
  詳細は下記参照
   https://www.terraform.io/docs/language/settings/backends/s3.html

   backend にs3を使用する場合は事前にtfstateファイル用のs3バケットを作成する必要がある。
   scripts/create_s3_backend.sh で作成可能。
  */

  backend "s3" {
    bucket         = "tfstate-123456789012"  # 必要に応じて変更
    key            = "dev/terraform.tfstate" # 必要に応じて変更
    region         = "ap-northeast-1"
    encrypt        = true
    dynamodb_table = "TerraformStateLockTable" # 必要に応じて変更
  }
}

provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = {
      Environment = "dev"     # 必要に応じて変更
      Project     = "example" # 必要に応じて変更
      ManagedBy   = "terraform"
    }
  }
}

# CloudFrintのACM作成用
provider "aws" {
  region = "us-east-1"
  alias  = "virginia"

  default_tags {
    tags = {
      Environment = "dev"      # 要変更
      Project     = "example"  # 要変更
      ManagedBy   = "terraform"
    }
  }
}
