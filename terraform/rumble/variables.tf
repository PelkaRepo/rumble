variable "aws_region" {
  description = "AWS region from which to launch."
  default     = "us-west-2"
}

variable "lambda_zip_dir" {
  description = "Relative path to AWS Lambda zip file with handler"
  default     = "./bin"
}

variable "source_url" {
  description = "The source API from which to retrieve geo seismic data"
  default = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_day.geojson"
}
