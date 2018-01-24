variable "aws_region" {
  description = "AWS region from which to launch."
  default     = "us-west-2"
}

variable "lambda_zip_dir" {
  description = "Relative path to AWS Lambda zip file with handler"
  default     = "./bin"
}
