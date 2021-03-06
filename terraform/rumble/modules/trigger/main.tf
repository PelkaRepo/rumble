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
    source_arn = "${aws_cloudwatch_event_rule.on_cadence.arn}"
}

resource "aws_cloudwatch_event_rule" "on_cadence" {
    name = "on_cadence"
    description = "Fires every ${var.rumble_frequency} minutes"
    schedule_expression = "rate(${var.rumble_frequency} minutes)"
}

resource "aws_cloudwatch_event_target" "poll_seismic_source" {
    rule = "${aws_cloudwatch_event_rule.on_cadence.name}"
    target_id = "rumble"
    arn = "${var.function_arn}"
}
