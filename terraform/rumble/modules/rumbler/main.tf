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

resource "aws_sns_topic" "rumbler" {
  name = "rumbler"
}

resource "aws_sns_topic_policy" "default" {
  arn = "${aws_sns_topic.rumbler.arn}"

  policy = "${data.aws_iam_policy_document.sns-topic-policy.json}"
}

data "aws_iam_policy_document" "sns-topic-policy" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        "${var.aws_account_id}",
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "${aws_sns_topic.rumbler.arn}",
    ]

    sid = "__default_statement_ID"
  }
}

resource "aws_sns_topic_subscription" "receiver_of_rumbles" {
  topic_arn = "${aws_sns_topic.rumbler.arn}"
  protocol  = "sms"
  endpoint_auto_confirms = "true"
  endpoint  = "1-814-553-6737"
}
