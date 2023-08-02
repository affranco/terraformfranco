terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "smx-lab"
  region  = "us-west-2"
}
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "archive_file" "LambdaZipFile" {
  type        = "zip"
  source_file = "${path.module}/src/LambdaFunction.py"
  output_path = "${path.module}/LambdaFunction.zip"
}

module "iam" {
  source = "./modules/iam"
}

module "apigateway" {
  source = "./modules/apigateway"
  role_arn = module.iam.APIGWRole_arn
}

module "lambda" {
  source = "./modules/lambda"
  role_arn = module.iam.LambdaRole_arn
  archive_file_output_path = data.archive_file.LambdaZipFile.output_path
}

module "cloudwatch" {
  source = "./modules/cloudwatch"
  lambda_arn = module.lambda.lambda_arn
  lambda_name = module.lambda.lambda_function_name
}
