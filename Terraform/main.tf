#1. Terraform (Infrastructure Setup):
# Create IAM User and grant permissions to create s3 bucket and lambda on AWS cloud.
# Create IAM access key id and security access key to configure with AWS
# Commands to congifure your credentials with AWS to run tf files : aws configure

provider "aws" {
  region = var.region  # Choose your region
}

# Create S3 Bucket(private)
resource "aws_s3_bucket" "example_bucket" {
  bucket = "example-bucket"
  acl = "private"
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Lambda function to interact with CloudWatch and S3 
resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy"
  description = "Policy for Lambda function execution"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "logs:*"  
        Effect   = "Allow"
        Resource = "*" #granting permissions to all resources(log-events, log-streams, log-groups). you can specify for each log stream or log-group
      },
      {
        Action   = "s3:*"
        Effect   = "Allow"
        Resource = aws_s3_bucket.example_bucket.arn
      }
    ]
  })
}

# Attach IAM Policy to IAM Role
resource "aws_iam_role_policy_attachment" "lambda_role_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

data "external" "upload_lambda_zip" {
  program = ["python3", "./upload_lambda.py", aws_s3_bucket.example_bucket.bucket, "lambda.zip"]
}

# Create the Lambda Function
resource "aws_lambda_function" "example_lambda" {
  function_name = "example-lambda"
  runtime       = "nodejs14.x"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "index.handler"
  filename      = "lambda.zip"  #deployment package should be in the same directory as the terraform script

  source_code_hash = filebase64sha256("lambda.zip")

  environment {
    variables = {
      LOG_LEVEL = "info"
    }
  }

  depends_on = [aws_s3_bucket.example_bucket]
}


