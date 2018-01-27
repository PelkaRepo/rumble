variable "aws_account_id" {
  description = "AWS account ID. This is provided only for policies which explicitly need it defined."
  type    = "string"
  default     = "912167340146a"
}

variable "aws_region" {
  description = "AWS region from which to launch."
  type    = "string"
  default     = "us-west-2"
}

variable "lambda_zip_dir" {
  description = "Relative path to AWS Lambda zip file with handler"
  type = "string"
  default     = "./bin"
}

variable "source_url" {
  description = "The source API from which to retrieve geo seismic data"
  type    = "string"
  default = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_day.geojson"
}
