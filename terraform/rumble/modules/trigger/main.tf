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

resource "aws_lambda_permission" "allow_cloudwatch_to_rumble" {
    statement_id = "AllowExecutionFromCloudWatch-${var.function_name}"
    action = "lambda:InvokeFunction"
    function_name = "${var.function_name}"
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
    arn = "${var.function_arn}"
}
