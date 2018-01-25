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

resource "aws_lambda_permission" "allow_cloudwatch_to_rumble" {
    statement_id = "AllowExecutionFromCloudWatch-rumble"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.rumble.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.every_ten_minutes.arn}"
}

resource "aws_cloudwatch_event_rule" "every_ten_minutes" {
    name = "every-ten-minutes"
    description = "Fires every ten minutes"
    schedule_expression = "rate(10 minutes)"
}

resource "aws_cloudwatch_event_target" "poll_seismic_source" {
    rule = "${aws_cloudwatch_event_rule.every_ten_minutes.name}"
    target_id = "rumble"
    arn = "${aws_lambda_function.rumble.arn}"
}

resource "aws_lambda_function" "rumble" {
  filename         = "${var.lambda_zip_dir}/rumble.zip"
  function_name    = "rumble"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "index.rumbler"
  source_code_hash = "${base64sha256(file("${var.lambda_zip_dir}/rumble.zip"))}"
  runtime          = "nodejs4.3"

  environment {
    variables = {
      SOURCE_URL = "${var.source_url}"
    }
  }
}
