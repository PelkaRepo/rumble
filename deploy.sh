#!/bin/bash -e

if [ $(whoami) != "root" ]; then
  source ~/.bash_profile
fi

terraform init ./terraform/lambda/
terraform plan -out .terraform/terraform.tfplan ./terraform/lambda/
