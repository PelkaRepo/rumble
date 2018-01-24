terraform {
  backend "s3" {
    bucket = "tf-state-rumble"
    key    = "terraform.tfstate"
    region = "us-west-2"
  }
}

provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "rumble" {
  filename         = "${var.lambda_zip_dir}/rumble.zip"
  function_name    = "rumble"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "exports.rumbler"
  source_code_hash = "${base64sha256(file("${var.lambda_zip_dir}/rumble.zip"))}"
  runtime          = "nodejs4.3"

  environment {
    variables = {
      type = "string"
      default = "foo-bar"
    }
  }
}
