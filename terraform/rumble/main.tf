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
        "Service": "lambda.amazonaws.com",
        "Service": "sns.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_rights" {
  name = "lambda_rights"
  role = "${aws_iam_role.iam_for_lambda.id}"
  policy =  <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
              "SNS:Subscribe",
              "SNS:Publish",
              "SNS:ListSubscriptionsByTopic"
            ],
            "Effect": "Allow",
            "Resource": ["${module.rumbler.rumbler_arn}"]
        }
    ]
}
EOF
}


module "rumbler" {
  source  = "./modules/rumbler"
  aws_account_id = "${var.aws_account_id}"
  aws_region = "${var.aws_region}"
}

module "trigger" {
  source  = "./modules/trigger"
  aws_region = "${var.aws_region}"
  function_name = "${aws_lambda_function.rumble.function_name}"
  function_arn = "${aws_lambda_function.rumble.arn}"
}

resource "aws_lambda_function" "rumble" {
  filename         = "${var.lambda_zip_dir}/rumble.zip"
  function_name    = "rumble"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "index.rumbler"
  source_code_hash = "${base64sha256(file("${var.lambda_zip_dir}/rumble.zip"))}"
  runtime          = "nodejs4.3"

  environment {
    variables {
      RUMBLER_TOPIC_ARN = "${module.rumbler.rumbler_arn}",
      SOURCE_URL = "${var.source_url}"
    }
  }
}
